import datetime
from django.contrib.auth import authenticate, login
from django.contrib.auth.hashers import make_password, check_password
from django.contrib.auth.models import User, Group
from django.core.files.storage import FileSystemStorage
from django.http import HttpResponse, JsonResponse
from django.contrib import messages
from django.contrib.auth import update_session_auth_hash
from django.shortcuts import render, redirect, get_object_or_404




# Create your views here
from my_app.models import category, distributor, review, feedback, customer, product, stock, order_sub, orders

print(make_password("password"))

def log(request):
    return render(request, 'login.html')


def logout(request):
    return render(request, 'login.html')

def login_post(request):
    un = request.POST['username']
    psw = request.POST['password']
    data = authenticate(request, username=un, password=psw)

    if data is not None:
        login(request, data)
        if data.is_superuser:
            return redirect('/admin_home')
    else:
        return  HttpResponse("Invalid")
    #         messages.success(request, f"Welcome back, {data.username} 👋")
    #         return redirect('/admin_home')
    #
    # messages.error(request, "Invalid username or password.")
    # return redirect('/')



def change_password(request):
    return render(request, 'changePassword.html')



def change_password_post(request):
    if request.method != "POST":
        messages.error(request, "Invalid request method.")
        return redirect('/change_password')

    current = request.POST.get('oldpassword')
    newpass = request.POST.get('newpassword')
    confirmpass = request.POST.get('confirmpassword')

    user = request.user

    if not user.is_authenticated:
        messages.error(request, "You must be logged in to change your password.")
        return redirect('/')

    # Check old password
    if not check_password(current, user.password):
        messages.error(request, "Old password is incorrect.")
        return redirect('/change_password')

    # Check new passwords match
    if newpass != confirmpass:
        messages.error(request, "New passwords do not match.")
        return redirect('/change_password')

    # Prevent reusing the same password
    if check_password(newpass, user.password):
        messages.warning(request, "New password cannot be the same as your old one.")
        return redirect('/change_password')

    # Update password
    user.set_password(newpass)
    user.save()

    # Keep the user logged in after password change
    update_session_auth_hash(request, user)

    messages.success(request, "Password updated successfully.")
    return redirect('/admin_home')

# def change_password_post(request):
#     current = request.POST['oldpassword']
#     newpass = request.POST['newpassword']
#     confirmpass = request.POST['confirmpassword']
#     data = check_password(current,request.user.password)
#     if data:
#         if newpass == confirmpass:
#             obj = request.user
#             obj.set_password(newpass)
#             obj.save()
#             return HttpResponse("<script>alert('Update');window.location='/'</script>")
#         return HttpResponse("<script>alert('Incorrect');window.location='/change_password'</script>")
#     return HttpResponse("<script>alert('invalid');window.location='/change_password'</script>")


def forget_password(request):
    return render(request, 'forget_password.html')

def forget_password_post(request):
    username = request.POST['username']
    data = User.objects.filter(username=username)
    if data.exists():
        request.session['fid'] = data[0].id
        return redirect('/forget_password_set')



    return HttpResponse("<script>alert('invalid');window.location='/'</script>")


def forget_password_set(request):
    return render(request, 'forget_password_set.html')



def forget_password_set_post(request):
    newpass = request.POST['newpassword']
    confirmpass = request.POST['confirmpassword']
    if newpass == confirmpass:
        obj = User.objects.get(id=request.session['fid'])
        obj.set_password(newpass)
        obj.save()
        return HttpResponse("<script>alert('Update');window.location='/'</script>")

    return HttpResponse("<script>alert('Update');window.location='/'</script>")









def admin_home(request):
    return render(request,'admin/admin_home.html')

def admin_verify(request):
    distributordata = distributor.objects.filter(status='pending')
    return render(request, 'admin/admin_verify.html',{'distributordata':distributordata})

def accept_distributor(request,id):
    distributor.objects.filter(id=id).update(status='approve')
    return HttpResponse("<script>window.location='/admin_verify'</script>")

def reject_distributor(request,id):
    distributor.objects.filter(id=id).update(status='reject')
    return HttpResponse("<script>window.location='/admin_verify'</script>")


def admin_verified(request):
    distributordata = distributor.objects.filter(status='approve')
    return render(request, 'admin/admin_verified.html',{'distributordata':distributordata})


def admin_viewcustomer(request):
    customerdata = customer.objects.all()
    return render(request, 'admin/admin_viewcustomer.html',{'customerdata':customerdata})

def admin_review(request):
    reviewdata = review.objects.all().order_by('-review_date')
    return render(request, 'admin/admin_review.html', {'reviewdata': reviewdata})


def send_review(request):
    cid = request.POST['cid']
    uid = request.POST['uid']
    reviews = request.POST['reviews']
    rating = request.POST['rating']

    obj = review()
    obj.USER_id = cid
    obj.DISTRIBUTOR_id = uid
    obj.reviews = reviews
    obj.rating = int(rating)
    obj.review_date = datetime.datetime.now().date()
    obj.save()

    return JsonResponse({'status': 'ok'})

def view_review(request):
    cid = request.POST.get('cid')
    uid = request.POST.get('uid')
    data = review.objects.filter(USER_id=cid, DISTRIBUTOR_id=uid)
    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'reviews': i.reviews,
            'rating': i.rating,
            'review_date': i.review_date,
            'username': i.USER.name ,
            'distributor': i.DISTRIBUTOR.name
        })

    return JsonResponse({'status': 'ok', 'data': ar})


def delete_review(request,id):
    review.objects.filter(id=id).delete()
    return JsonResponse({'status':'ok'})

# def add_category_post(request):
#     category_name = request.POST['Category']
#     obj=category()
#     obj.category_name=category_name
#     obj.save()
#     return HttpResponse("<script>alert(' Category Added successfully');window.location='/admin_category'</script>")
#
# def edit_category_post(request,id):
#     cat=request.POST['Category']
#     category.objects.filter(id=id).update(category_name=cat)
#     return HttpResponse("<script>alert(' Category Updated successfully');window.location='/admin_category'</script>")
#
# def delete_category(request,id):
#     data=category.objects.get(id=id)
#     data.delete()
#     return HttpResponse("<script>alert(' Category Deleted successfully');window.location='/admin_category'</script>")

def admin_category(request):
    data = category.objects.all()
    return render(request, 'admin/admin_category.html', {'data': data})

def admin_add_category(request):
    return render(request, 'admin/add_category.html')

def add_category_post(request):
    category_name = request.POST['Category']
    obj = category(category_name=category_name)
    obj.save()
    messages.success(request, f"Category '{category_name}' added successfully!")
    return redirect('/admin_category')

def edit_category(request, id):
    data = get_object_or_404(category, id=id)
    return render(request, 'admin/edit_category.html', {'data': data})

def edit_category_post(request, id):
    cat = request.POST['Category']
    category.objects.filter(id=id).update(category_name=cat)
    messages.success(request, f"Category updated to '{cat}' successfully!")
    return redirect('/admin_category')

# @require_POST
def delete_category(request, id):
    obj=category.objects.get(id=id)
    name = obj.category_name
    obj.delete()
    messages.error(request, f"Category '{name}' deleted.")
    return redirect('/admin_category')






# def admin_feedback(request):
#     feeddata = feedback.objects.filter(type='user')
#     return render(request,'admin/admin_feedback.html',{'feeddata':feeddata})
# # def admin_feedback(request):
# #     feeddata = feedback.objects.select_related('USER', 'DISTRIBUTOR').order_by('-feedback_date')
# #     return render(request, 'admin/admin_feedback.html', {'feeddata': feeddata})
#
# def send_feedback(request):
#     cid = request.POST['cid']
#     feedbacks = request.POST['feedbacks']
#     uid = request.POST['uid']
#     obj = feedback()
#     obj.feedback_date = datetime.datetime.now().date()
#
#     obj.feedbacks = feedbacks
#     obj.USER_id = cid
#     obj.DISTRIBUTOR_id = uid
#     obj.save()
#     return JsonResponse({'status': 'ok'})
# from django.utils import timezone

# ========== SEND FEEDBACK (Customer or Distributor) ==========
def send_feedback(request):
    if request.method == 'POST':
        feedbacks = request.POST.get('feedbacks')
        cid = request.POST.get('cid')  # customer id (if user)
        uid = request.POST.get('uid')  # distributor id (if distributor)

        if not feedbacks:
            return JsonResponse({'status': 'error', 'message': 'Feedback text missing'})

        obj = feedback()
        obj.feedbacks = feedbacks
        obj.feedback_date = datetime.datetime.now()

        # Identify sender type
        if cid:
            obj.USER_id = cid
            obj.type = 'user'
        elif uid:
            obj.DISTRIBUTOR_id = uid
            obj.type = 'distributor'
        else:
            return JsonResponse({'status': 'error', 'message': 'No sender ID provided'})

        obj.save()
        return JsonResponse({'status': 'ok', 'message': 'Feedback sent successfully'})

    return JsonResponse({'status': 'error', 'message': 'Invalid request method'})


# ========== ADMIN: VIEW ALL FEEDBACKS ==========
def admin_feedback(request):
    feeddata = feedback.objects.all().order_by('-feedback_date')
    return render(request, 'admin/admin_feedback.html', {'feeddata': feeddata})


# ========== API: GET FEEDBACKS (For Flutter / Mobile) ==========
def view_feedback(request):
    cid = request.POST.get('cid')
    uid = request.POST.get('uid')
    data = feedback.objects.filter(USER_id=cid, DISTRIBUTOR_id=uid).order_by('-feedback_date')
    feedback_list = []

    for f in data:
        feedback_list.append({
            'id': f.id,
            'feedbacks': f.feedbacks,
            'feedback_date': f.feedback_date,
            'username': f.USER.name if f.USER else None,
            'distributor': f.DISTRIBUTOR.name if f.DISTRIBUTOR else None,
            'type': f.type,
        })

    return JsonResponse({'status': 'ok', 'data': feedback_list})











######################  DISTRIBUTOR   ###########################



def distributor_registration(request):
    profile_image = request.FILES['file']
    proof = request.FILES['file1']
    fs = FileSystemStorage()
    path = fs.save(profile_image.name,profile_image,)
    path1 = fs.save(proof.name , proof)

    name = request.POST['name']
    email = request.POST['email']
    phone = request.POST['phone']
    password = request.POST['password']
    address = request.POST['address']
    pincode = request.POST['pincode']
    place = request.POST['place']
    post = request.POST['post']
    bio = request.POST['bio']
    latitude = request.POST['latitude']
    longitude = request.POST['longitude']
    print(name)
    print(email)
    print(phone)
    print(address)
    print(pincode)
    obj=User()
    obj.username=email
    obj.password=make_password(password)
    obj.save()
    obj.groups.add(Group.objects.get(name='distributor'))


    ob = distributor()
    ob.profile_image = fs.url(path)
    ob.name = name
    ob.email = email
    ob.phone = phone
    ob.address = address
    ob.pincode = pincode
    ob.place = place
    ob.post = post
    ob.bio = bio
    ob.latitude = latitude
    ob.longitude = longitude
    ob.proof = fs.url(path1)
    ob.status='pending'
    ob.LOGIN=obj
    ob.save()
    return JsonResponse({'status':'ok'})


def distributor_view_profile(request):
    uid = request.POST['uid']
    data = distributor.objects.filter(id=uid)

    ar = []
    for i in data:
        ar.append({'id': i.id, 'name': i.name, 'email': i.email, 'phone': i.phone, 'profile_image': i.profile_image,
                   'bio': i.bio, 'address': i.address, 'place': i.place, 'pincode': i.pincode, 'post': i.post,'latitude':i.latitude,'longitude':i.longitude,'proof':i.proof})

    return JsonResponse({'status': 'ok', 'data': ar})



def edit_distributor_profile(request):
    uid = request.POST['uid']
    if 'file' in request.FILES:
        profile_image = request.FILES['file']
        fs = FileSystemStorage()
        path = fs.save(profile_image.name, profile_image)
        distributor.objects.filter(id=uid).update(profile_image=fs.url(path))


    if 'file1' in request.FILES:
        proof = request.FILES['file1']
        fs = FileSystemStorage()
        path1 = fs.save(proof.name, proof)
        distributor.objects.filter(id=uid).update(proof=fs.url(path1))

    name = request.POST['name']
    phone = request.POST['phone']
    address = request.POST['address']
    pincode = request.POST['pincode']
    place = request.POST['place']
    post = request.POST['post']
    bio = request.POST['bio']
    latitude = request.POST['latitude']
    longitude = request.POST['longitude']
    uid = request.POST['uid']
    distributor.objects.filter(id=uid).update(name=name,phone=phone,address=address,pincode=pincode,place=place,post=post,bio=bio,latitude=latitude,longitude=longitude)
    return JsonResponse({'status':'ok'})





def distributor_view_customer(request):
    cid=request.POST['cid']
    data=customer.objects.all()
    ar=[]
    for i in data:
        ar.append({'id':i.id,'name':i.name,'email':i.email,'phone':i.phone,'profile_image':i.profile_image,'bio':i.bio,'address':i.address,'place':i.place,'pincode':i.pincode,'post':i.post})

    return JsonResponse({'status':'ok','data':ar})





def distributor_view_distributor(request):
    uid = request.POST['uid']
    data = distributor.objects.all()

    ar = []
    for i in data:
        ar.append({'id': i.id, 'name': i.name, 'email': i.email, 'phone': i.phone, 'profile_image': i.profile_image,
                   'bio': i.bio, 'address': i.address, 'place': i.place, 'pincode': i.pincode, 'post': i.post,
                   'latitude': i.latitude, 'longitude': i.longitude, 'proof': i.proof})

    return JsonResponse({'status': 'ok', 'data': ar})











def customer_search_page(request):

    return JsonResponse({'status':'ok'})


def customer_follow(request):
    return JsonResponse({'status':'ok'})

def customer_unfollow(request):
    return JsonResponse({'status':'ok'})

def customer_like(request):
    return JsonResponse({'status':'ok'})

def customer_comment(request):
    return JsonResponse({'status':'ok'})

def customer_share(request):
    return JsonResponse({'status':'ok'})

def customer_save(request):
    return JsonResponse({'status':'ok'})


def customer_view_notifications(request):
    return JsonResponse({'status':'ok'})

def customer_view_bill(request):
    return JsonResponse({'status':'ok'})

def distributor_make_bill(request):

    return JsonResponse({'status':'ok'})

def distributor_edit_bill(request):
    return JsonResponse({'status':'ok'})

def distributor_delete_bill(request):
    return JsonResponse({'status':'ok'})

def distributor_send_bill(request):
    return JsonResponse({'status':'ok'})

def customer_receive_bill(request):
    return JsonResponse({'status':'ok'})













def distributor_delete_customers(request):
    return JsonResponse({'status':'ok'})












def view_category(request):

    data = category.objects.all()
    print(data)
    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'category_name': i.category_name,
        })
    print(ar)
    return JsonResponse({'status':'ok','data':ar})




def login_page(request):
    un = request.POST['username']
    psw = request.POST['password']
    print(un, psw)
    try:
        data = authenticate(request, username=un, password=psw)
        if data is not None:
            login(request, data)
            print(request.user.id)
            if data.groups.filter(name="distributor").exists():
                print("Distributor")
                if distributor.objects.filter(LOGIN=request.user.id,status="approve").exists():
                    uid = distributor.objects.get(LOGIN=request.user.id).id
                    return JsonResponse({'status':'distok','uid':str(uid)}, status=200)
                else:
                    return JsonResponse({'status': 'invalid credentials'}, status=400)

            elif data.groups.filter(name="customer").exists():
                print("Customer")
                cid = customer.objects.get(LOGIN=request.user.id).id
                print(cid)
                return JsonResponse({'status': 'custok', 'cid': str(cid)}, status=200)
            else:
                return JsonResponse({'status': 'not found'}, status=400)
        else:
            return JsonResponse({'status': 'invalid credentials'}, status=400)
    except Exception as e:
        print(f"Error: {e}")
    return JsonResponse({'status': 'error', 'message': str(e)}, status=500)




def password_change(request):
    uid = request.POST['uid']
    newpass = request.POST['newpassword']
    lid=distributor.objects.get(id=uid).LOGIN_id
    User.objects.filter(id=lid).update(password=make_password(newpass))
    return JsonResponse({'status':'ok'})



def customer_change_password(request):
    cid = request.POST['cid']
    newpass = request.POST['newpassword']
    lid=customer.objects.get(id=cid).LOGIN_id
    User.objects.filter(id=lid).update(password=make_password(newpass))
    return JsonResponse({'status':'ok'})




def distributor_view_product(request):
    # uid = request.POST['uid']
    # if not uid:
    #     return JsonResponse({'status': 'error', 'message': 'No distributor id'}, status=400)
    data = product.objects.all()
    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'product_name': i.product_name,
            # 'price': i.price,
            'image': i.image,
            'description': i.description,
            'quantity': i.quantity,
            'CATEGORY': i.CATEGORY.id,
            'CATEGORY_NAME': getattr(i.CATEGORY, 'category_name', ''),
        })
    return JsonResponse({'status': 'ok', 'data': ar})




def view_product(request):
    productdata = product.objects.all()
    return render(request, 'admin/view_product.html', {'productdata': productdata})


def add_product(request):
    categorydtata = category.objects.all()
    return render(request,"admin/add_product.html",{'categorydata':categorydtata})



def add_product_post(request):
    product_name = request.POST['product_name']
    img = request.FILES['image']
    fs=FileSystemStorage()
    image=fs.save(img.name,img)
    # price = request.POST['price']
    quantity = request.POST['quantity']
    description = request.POST['description']
    category = request.POST['category']
    # obj = product(product_name=product_name,image=fs.url(image),price=price,quantity=quantity,description=description,CATEGORY_id=category)
    obj = product(product_name=product_name,image=fs.url(image),quantity=quantity,description=description,CATEGORY_id=category)
    obj.save()
    # messages.success(request, f"Category '{category_name}' added successfully!")
    return redirect('/view_product')



def edit_product(request,id):
    data = product.objects.get(id=id)
    categorydata = category.objects.all()
    return render(request, 'admin/edit_product.html',{'data': data,'categorydata':categorydata})


def edit_product_post(request,id):
    product_name = request.POST['product_name']

    # price = request.POST['price']
    quantity = request.POST['quantity']
    description = request.POST['description']
    category = request.POST['category']
    if 'image' in request.FILES:
        img = request.FILES['image']
        fs = FileSystemStorage()
        image = fs.save(img.name, img)
        product.objects.filter(id=id).update( image=fs.url(image))

    # product.objects.filter(id=id).update(product_name=product_name, price=price, quantity=quantity,description=description, CATEGORY_id=category)
    product.objects.filter(id=id).update(product_name=product_name,quantity=quantity,description=description, CATEGORY_id=category)

    return redirect('/view_product')



def delete_product(request, id):
    obj = product.objects.get(id=id)

    obj.delete()
    # messages.error(request, f"Category '{name}' deleted.")
    return redirect('/view_product')








def distributor_products(request):
    uid = request.POST['uid']
    data = stock.objects.filter(DISTRIBUTOR_id=uid)
    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'product_name': i.PRODUCT.product_name,
            'price': i.price,
            'image': i.PRODUCT.image,
            'description': i.PRODUCT.description,
            'quantity': i.quantity,
            'CATEGORY': i.PRODUCT.CATEGORY.id,
            'CATEGORY_NAME': getattr(i.PRODUCT.CATEGORY, 'category_name', ''),
        })
    return JsonResponse({'status': 'ok', 'data': ar})




def add_stock(request):
    quantity = request.POST['quantity']
    uid= request.POST['uid']
    pid = request.POST['pid']
    price = request.POST['price']
    obj = stock()
    obj.quantity = quantity
    obj.price = price
    obj.DISTRIBUTOR_id = uid
    obj.PRODUCT_id = pid
    obj.save()

    return JsonResponse({'ststus':'ok'})


def edit_stock(request):
    quantity = request.POST['quantity']
    # uid = request.POST['uid']
    pid = request.POST['pid']
    price = request.POST['price']

    stock.objects.filter(id = pid).update(price = price, quantity = quantity)
    return JsonResponse({'ststus':'ok'})





def delete_distributor_product(request,id):
    stock.objects.filter(id=id).delete()
    return JsonResponse({'ststus':'ok'})





def customer_view_products(request):



    data = stock.objects.all()
    ar = []
    for i in data:
        ar.append({
            'distributor_name':i.DISTRIBUTOR.name,
            'id': i.id,
            'product_name': i.PRODUCT.product_name,
            'price': i.price,
            'image': i.PRODUCT.image,
            'description': i.PRODUCT.description,
            'quantity': i.quantity,
            'CATEGORY': i.PRODUCT.CATEGORY.id,
            'CATEGORY_NAME': getattr(i.PRODUCT.CATEGORY, 'category_name', ''),
        })
    return JsonResponse({'status': 'ok', 'data': ar})










############################## CUSTOMER  ##############################################


def customer_registration(request):
    profile_image = request.FILES['file']
    fs = FileSystemStorage()
    path = fs.save(profile_image.name, profile_image, )

    name = request.POST['name']
    email = request.POST['email']
    phone = request.POST['phone']
    password = request.POST['password']
    address = request.POST['address']
    pincode = request.POST['pincode']
    place = request.POST['place']
    post = request.POST['post']
    bio = request.POST['bio']

    obj = User()
    obj.username = email
    obj.password = make_password(password)
    obj.save()
    obj.groups.add(Group.objects.get(name='customer'))

    ob = customer()
    ob.profile_image = fs.url(path)
    ob.name = name
    ob.email = email
    ob.phone = phone
    ob.address = address
    ob.pincode = pincode
    ob.place = place
    ob.post = post
    ob.bio = bio
    ob.LOGIN = obj
    ob.save()
    return JsonResponse({'status': 'ok'})








def customer_view_profile(request):
    cid=request.POST['cid']
    data=customer.objects.filter(id=cid)
    ar=[]
    for i in data:
        ar.append({'id':i.id,'name':i.name,'email':i.email,'phone':i.phone,'profile_image':i.profile_image,'bio':i.bio,'address':i.address,'place':i.place,'pincode':i.pincode,'post':i.post})

    return JsonResponse({'status':'ok','data':ar})


def edit_customer_profile(request):
    cid = request.POST['cid']
    if 'file' in request.FILES:
        profile_image = request.FILES['file']
        fs = FileSystemStorage()
        path = fs.save(profile_image.name, profile_image)
        customer.objects.filter(id=cid).update(profile_image=fs.url(path))


    name = request.POST['name']
    phone = request.POST['phone']
    address = request.POST['address']
    pincode = request.POST['pincode']
    place = request.POST['place']
    post = request.POST['post']
    bio = request.POST['bio']
    cid = request.POST['cid']
    customer.objects.filter(id=cid).update(name=name,phone=phone,address=address,pincode=pincode,place=place,post=post,bio=bio)
    return JsonResponse({'status':'ok'})




def customer_view_distributor(request):
    uid = request.POST['uid']
    data = distributor.objects.all()

    ar = []
    for i in data:
        ar.append({'id': i.id, 'name': i.name, 'email': i.email, 'phone': i.phone, 'profile_image': i.profile_image,
                   'bio': i.bio, 'address': i.address, 'place': i.place, 'pincode': i.pincode, 'post': i.post,'latitude':i.latitude,'longitude':i.longitude,'proof':i.proof})

    return JsonResponse({'status': 'ok', 'data': ar})




def addproduct(request):


    cid = request.POST['cid']
    uid = request.POST['uid']
    obj1=orders()
    obj1.orders = orders
    obj1.payment_status = 'pending'
    obj1.payment_date = datetime.datetime.now().date()
    obj1.date = datetime.datetime.now().date()
    obj1.USER_id = cid
    obj1.DISTRIBUTOR_id = uid
    obj1.save()

    quantity=request.POST['quantity']
    pid = request.POST['pid']
    oid = request.POST['oid']
    obj=order_sub()
    obj.quantity=quantity
    obj.PRODUCT_id=pid
    obj.ORDER_id=oid
    obj.save()



    return JsonResponse({'status':'ok'})

