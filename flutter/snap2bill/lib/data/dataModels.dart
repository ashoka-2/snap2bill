
class ProductData {
  final String id;
  final String productName;
  final String price;
  final String image;
  final String description;
  final String categoryName;
  final String categoryId;
  final String distributorId;
  final String distributorName;
  final String distributorImage;
  final String distributorPhone;
  final bool isLiked; // ✅ Added for Wishlist Sync

  ProductData({
    required this.id,
    required this.productName,
    required this.price,
    required this.image,
    required this.description,
    required this.categoryName,
    required this.categoryId,
    required this.distributorId,
    required this.distributorName,
    required this.distributorImage,
    required this.distributorPhone,
    required this.isLiked, // ✅ Constructor update
  });

  /// ✅ USED BY BOTH CUSTOMER & DISTRIBUTOR HOME PAGES
  factory ProductData.fromJson(
      Map<String, dynamic> json,
      String ip,
      ) {
    String joinUrl(String base, String path) {
      if (path.isEmpty || path == "null") return "";
      if (base.endsWith("/") && path.startsWith("/")) {
        return base + path.substring(1);
      }
      if (!base.endsWith("/") && !path.startsWith("/")) {
        return "$base/$path";
      }
      return base + path;
    }

    return ProductData(
      id: json['id'].toString(),
      productName: json['product_name'] ?? "",
      price: json['price'].toString(),
      image: joinUrl(ip, json['image'] ?? ""),
      description: json['description'] ?? "",
      categoryName: json['CATEGORY_NAME'] ?? "All",
      categoryId: json['CATEGORY']?.toString() ?? "",
      distributorId: json['distributor_id']?.toString() ?? "",
      distributorName: json['distributor_name'] ?? "",
      distributorImage: joinUrl(ip, json['distributor_image'] ?? ""),
      distributorPhone: json['distributor_phone'] ?? "",
      isLiked: json['is_liked'] ?? false, // ✅ Mapping 'is_liked' from Django JsonResponse
    );
  }
}

/// -------------------------------------------------------------

class CategoryData {
  final String id;
  final String name;

  CategoryData({
    required this.id,
    required this.name,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['id'].toString(),
      name: json['category_name'] ?? "",
    );
  }
}