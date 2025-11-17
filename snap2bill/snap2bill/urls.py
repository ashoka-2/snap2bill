"""snap2bill URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path, include

from my_app import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('',views.log),
    path("__reload__/", include("django_browser_reload.urls")),
    path('login_post',views.login_post),
    path('logout',views.logout),
    path('change_password',views.change_password),
    path('change_password_post', views.change_password_post),
    path('forget_password', views.forget_password),
    path('forget_password_post', views.forget_password_post),
    path('forget_password_set', views.forget_password_set),
    path('forget_password_set_post', views.forget_password_set_post),

    path('admin_home',views.admin_home),
    path('admin_verify', views.admin_verify),
    path('admin_verified', views.admin_verified),
    path('admin_viewcustomer', views.admin_viewcustomer),
    path('admin_review',views.admin_review),
    path('send_review',views.send_review),
    path('view_review',views.view_review),


    path('admin_category',views.admin_category),
    path('admin_add_category',views.admin_add_category),
    path('add_category_post',views.add_category_post),
    path('edit_category/<id>',views.edit_category),
    path('edit_category_post/<id>', views.edit_category_post),
    path('delete_category/<id>',views.delete_category),



    path('admin_feedback',views.admin_feedback),
    path('send_feedback',views.send_feedback),
    path('view_feedback',views.view_feedback),
    path('distributor_registration',views.distributor_registration),
    path('customer_registration',views.customer_registration),
    path('accept_distributor/<id>',views.accept_distributor),
    path('reject_distributor/<id>',views.reject_distributor),
    path('view_category',views.view_category),
    path('login_page',views.login_page),
    path('distributor_view_profile',views.distributor_view_profile),
    path('customer_view_profile',views.customer_view_profile),
    path('customer_search_page',views.customer_search_page),
    path('customer_view_distributor', views.customer_view_distributor),
    path('edit_customer_profile', views.edit_customer_profile),
    path('customer_follow', views.customer_follow),
    path('customer_unfollow', views.customer_unfollow),
    path('customer_like', views.customer_like),
    path('customer_comment', views.customer_comment),
    path('customer_share', views.customer_share),
    path('customer_save', views.customer_save),
    path('customer_view_notifications', views.customer_view_notifications),
    path('customer_view_bill', views.customer_view_bill),
    path('distributor_make_bill', views.distributor_make_bill),
    path('distributor_edit_bill', views.distributor_edit_bill),
    path('distributor_delete_bill', views.distributor_delete_bill),
    path('distributor_send_bill', views.distributor_send_bill),
    path('customer_receive_bill', views.customer_receive_bill),
    path('distributor_view_product',views.distributor_view_product),
    path('distributor_delete_customers',views.distributor_delete_customers),
    path('distributor_view_customer',views.distributor_view_customer),
    path('distributor_view_distributor', views.distributor_view_distributor),
    path('edit_distributor_profile',views.edit_distributor_profile),


    path('password_change',views.password_change),
    path('customer_change_password',views.customer_change_password),


    path('distributor_products',views.distributor_products),

    path('view_product',views.view_product),
    path('add_product',views.add_product),
    path('add_product_post',views.add_product_post),
    path('edit_product/<id>',views.edit_product),
    path('edit_product_post/<id>', views.edit_product_post),
    path('delete_product/<id>',views.delete_product),


    path('add_stock',views.add_stock),
    path('edit_stock', views.edit_stock),
    path('view_stock', views.view_stock),
    path('delete_stock', views.delete_stock),

]

urlpatterns+= static(settings.MEDIA_URL,document_root=settings.MEDIA_ROOT)