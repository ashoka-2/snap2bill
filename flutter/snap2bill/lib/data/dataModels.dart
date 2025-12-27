/// =============================================================
/// DATA MODELS
/// Used across Customer & Distributor modules
/// =============================================================

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
  bool isLiked; // ✅ Wishlist sync flag (mutable for UI toggle)

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
    required this.isLiked,
  });

  /// -----------------------------------------------------------
  /// FACTORY: Used by both Customer & Distributor Home Pages
  /// -----------------------------------------------------------
  factory ProductData.fromJson(
      Map<String, dynamic> json,
      String ip,
      ) {
    /// 🔐 Safe URL joiner
    String joinUrl(String base, String path) {
      if (path.isEmpty || path == "null") return "";
      if (path.startsWith("http")) return path;

      if (base.endsWith("/") && path.startsWith("/")) {
        return base + path.substring(1);
      }
      if (!base.endsWith("/") && !path.startsWith("/")) {
        return "$base/$path";
      }
      return base + path;
    }

    return ProductData(
      id: json['id']?.toString() ?? "",
      productName: json['product_name'] ?? "",
      price: json['price']?.toString() ?? "0",
      image: joinUrl(ip, json['image'] ?? ""),
      description: json['description'] ?? "",
      categoryName: json['CATEGORY_NAME'] ?? "All",
      categoryId: json['CATEGORY']?.toString() ?? "",
      distributorId: json['distributor_id']?.toString() ?? "",
      distributorName: json['distributor_name'] ?? "",
      distributorImage: joinUrl(ip, json['distributor_image'] ?? ""),
      distributorPhone: json['distributor_phone'] ?? "",
      isLiked: json['is_liked'] == true, // ✅ backend truth
    );
  }
}

/// =============================================================
/// CATEGORY MODEL
/// =============================================================

class CategoryData {
  final String id;
  final String name;

  CategoryData({
    required this.id,
    required this.name,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['id']?.toString() ?? "",
      name: json['category_name'] ?? "",
    );
  }
}
