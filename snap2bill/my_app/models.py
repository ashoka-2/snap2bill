from django.contrib.auth.models import User
from django.db import models

# Create your models here.
class customer(models.Model):
    name = models.CharField(max_length=100)
    email = models.CharField(max_length=100)
    phone = models.CharField(max_length=100)
    profile_image = models.CharField(max_length=100)
    bio = models.CharField(max_length=500)
    address = models.CharField(max_length=200)
    place = models.CharField(max_length=100)
    pincode = models.CharField(max_length=100)
    post = models.CharField(max_length=100)
    LOGIN = models.ForeignKey(User,models.CASCADE)


class distributor(models.Model):
    name = models.CharField(max_length=100)
    email = models.CharField(max_length=100)
    phone = models.CharField(max_length=100)
    profile_image = models.CharField(max_length=100)
    bio = models.CharField(max_length=500)
    address = models.CharField(max_length=200)
    place = models.CharField(max_length=100)
    pincode = models.CharField(max_length=100)
    post = models.CharField(max_length=100)
    latitude = models.CharField(max_length=100)
    longitude = models.CharField(max_length=100)
    proof = models.CharField(max_length=100)
    status=models.CharField(max_length=100)
    LOGIN = models.ForeignKey(User,models.CASCADE)




class category(models.Model):
    category_name = models.CharField(max_length=100)



class product(models.Model):
    product_name = models.CharField(max_length=100)
    # price = models.CharField(max_length=100)
    image = models.CharField(max_length=100)
    description = models.CharField(max_length=100)
    quantity = models.CharField(max_length=100)
    CATEGORY = models.ForeignKey(category,models.CASCADE)













# class review(models.Model):
#     reviews = models.CharField(max_length=100)
#     review_date = models.CharField(max_length=100)
#     rating = models.CharField(max_length=100)
#     USER = models.ForeignKey(customer,models.CASCADE)
#     DISTRIBUTOR = models.ForeignKey(
#         distributor,
#         on_delete=models.SET_NULL,
#         null=True,
#         blank=True
#     )


class review(models.Model):
    reviews = models.TextField()
    rating = models.IntegerField()
    review_date = models.CharField(max_length=100)  # 👈 back to simple string
    USER = models.ForeignKey('customer', on_delete=models.SET_NULL, null=True, blank=True)
    DISTRIBUTOR = models.ForeignKey('distributor', on_delete=models.SET_NULL, null=True, blank=True)

    def __str__(self):
        user_name = self.USER.name if self.USER else "Unknown User"
        dist_name = self.DISTRIBUTOR.name if self.DISTRIBUTOR else "Unknown Distributor"
        return f"{user_name} → {dist_name} ({self.rating}★)"


# class feedback(models.Model):
#     feedbacks = models.CharField(max_length=100)
#     feedback_date = models.CharField(max_length=100)
#     USER = models.ForeignKey(customer,models.CASCADE)
#     DISTRIBUTOR = models.ForeignKey(
#         distributor,
#         on_delete=models.SET_NULL,
#         null=True,
#     )
#     type = models.CharField(max_length=100)

class feedback(models.Model):
    feedbacks = models.TextField()
    feedback_date = models.CharField(max_length=100)
    USER = models.ForeignKey(customer, on_delete=models.SET_NULL, null=True, blank=True)
    DISTRIBUTOR = models.ForeignKey(distributor, on_delete=models.SET_NULL, null=True, blank=True)
    type = models.CharField(max_length=100)  # 'user' or 'distributor'

    def __str__(self):
        if self.USER:
            return f"User Feedback: {self.USER.name}"
        elif self.DISTRIBUTOR:
            return f"Distributor Feedback: {self.DISTRIBUTOR.name}"
        return f"Feedback #{self.id}"








class payment(models.Model):
    amount = models.CharField(max_length=100)
    amount_date = models.CharField(max_length=100)
    status= models.CharField(max_length=100)
    USER=models.ForeignKey(customer,models.CASCADE)





class stock(models.Model):
    price = models.CharField(max_length=100)
    quantity = models.CharField(max_length=100)
    DISTRIBUTOR = models.ForeignKey(distributor,models.CASCADE)
    PRODUCT = models.ForeignKey(product,models.CASCADE)



class order(models.Model):
    payment_status = models.CharField(max_length=100)
    payment_date = models.CharField(max_length=100)
    date = models.CharField(max_length=100)
    amount = models.CharField(max_length=100)
    USER = models.ForeignKey(customer,models.CASCADE)
    DISTRIBUTOR = models.ForeignKey(distributor,models.CASCADE)

class order_sub(models.Model):
    ORDER= models.ForeignKey(order,models.CASCADE)

    quantity= models.CharField(max_length=100)
    STOCK = models.ForeignKey(stock,models.CASCADE)


class cart(models.Model):
    PRODUCT = models.ForeignKey(product,models.CASCADE)
    ORDER= models.ForeignKey(order,models.CASCADE)
    quantity= models.CharField(max_length=100)





















