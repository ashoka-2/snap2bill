import datetime
from django.contrib.auth import authenticate, login , logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.hashers import make_password, check_password
from django.contrib.auth.models import User, Group
from django.core.files.storage import FileSystemStorage
from django.http import HttpResponse, JsonResponse
from django.contrib import messages
from django.contrib.auth import update_session_auth_hash
from django.shortcuts import render, redirect, get_object_or_404




# Create your views here
from django.views.decorators.csrf import csrf_exempt

from my_app.models import category, distributor, review, feedback, customer, product, stock, order_sub, order, payment, \
    cart, wishlist

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


@login_required(login_url='')
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



# def forget_password_set_post(request):
#     newpass = request.POST['newpassword']
#     confirmpass = request.POST['confirmpassword']
#     if newpass == confirmpass:
#         obj = User.objects.get(id=request.session['fid'])
#         obj.set_password(newpass)
#         obj.save()
#         return HttpResponse("<script>alert('Update');window.location='/'</script>")
#
#     return HttpResponse("<script>alert('Update');window.location='/'</script>")


def forget_password_set_post(request):
    if request.method == "POST":
        newpass = request.POST.get('newpassword')
        confirmpass = request.POST.get('confirmpassword')

        # 1. Server-Side Validation: Check if passwords match
        if newpass != confirmpass:
            # Send error message to be caught by the Snackbar
            messages.error(request, "Passwords do not match!")
            # Redirect back to the change password page (replace 'change_password_page' with your actual URL name)
            return redirect('change_password_page')

            # 2. Update Password Logic
        try:
            # Check if session ID exists
            if 'fid' in request.session:
                obj = User.objects.get(id=request.session['fid'])
                obj.set_password(newpass)
                obj.save()

                # Optional: Clear the session variable so they can't change it again
                del request.session['fid']

                messages.success(request, "Password updated successfully!")
                return redirect('/')  # Redirect to Login
            else:
                messages.error(request, "Session expired. Please try again.")
                return redirect('/')

        except User.DoesNotExist:
            messages.error(request, "User not found.")
            return redirect('/')

    return redirect('/')




def admin_home(request):
    customer_count = customer.objects.count()
    pending_count = distributor.objects.filter(status='pending').count()
    verified_count = distributor.objects.filter(status='approve').count()
    product_count = product.objects.count()
    feedback_count = feedback.objects.filter(type="distributor").count()
    cust_feedback_count = feedback.objects.filter(type="user").count()
    review_count = review.objects.count()
    category_count = category.objects.count()


    context = {
        'customer_count': customer_count,
        'pending_count': pending_count,
        'verified_count': verified_count,
        'product_count': product_count,
        'feedback_count': feedback_count,
        'cust_feedback_count': cust_feedback_count,
        'review_count':review_count,
        'category_count': category_count,
    }
    return render(request, 'admin/admin_home.html', context)

def admin_setting(request):
    return render(request,'admin/settingpage.html')

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
    obj.rating = float  (rating)
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
        obj.feedback_date = datetime.datetime.now().date()

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
def customer_feedbacks(request):
    feeddata = feedback.objects.filter(type="user").order_by('-feedback_date')
    return render(request, 'admin/admin_feedback.html', {'feeddata': feeddata})


def distributor_feedbacks(request):
    feeddata = feedback.objects.filter(type="distributor").order_by('-feedback_date')
    return render(request, 'admin/viewDistributorFeedbacks.html', {'feeddata': feeddata})


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
    # cid=request.POST['cid']
    uid = request.POST['uid']

    # data=customer.objects.all()
    data = order.objects.filter(DISTRIBUTOR=uid)
    ar=[]
    for i in data:
        ar.append({
            'id': i.id,
            'name':i.USER.name,
            'email':i.USER.email,
            'phone':i.USER.phone,
            'profile_image':i.USER.profile_image,
            'bio':i.USER.bio,
            'address':i.USER.address,
            'place':i.USER.place,
            'pincode':i.USER.pincode,
            'post':i.USER.post
        })

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



@csrf_exempt
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
                if distributor.objects.filter(LOGIN=request.user.id, status__in=['approve', 'pending']).exists():
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


#
# def emailVerify(request):
#     username = request.POST['username']
#     data = User.objects.filter(username=username)
#
#
#     return JsonResponse({'status':'ok'})
#
#
# def forgotPasswordDistributor(request):
#     newpass = request.POST['newpassword']
#     confirmpass = request.POST['confirmpassword']
#     if newpass == confirmpass:
#         obj = User.objects.get(id=uid)
#         obj.set_password(newpass)
#         obj.save()
#     return JsonResponse({'status':'ok'})
#
#



def forgotemail(request):
    import random
    import smtplib
    email = request.POST['email']
    print(email)
    data = User.objects.filter(username=email)
    print(data)
    if data.exists():
        otp = str(random.randint(111111, 999999))
        print(otp)
        # *✨ Python Email Codeimport smtplib*

        from email.mime.text import MIMEText
        from email.mime.multipart import MIMEMultipart

        # ✅ Gmail credentials (use App Password, not real password)
        try:
            sender_email = "choudharyashok1230@gmail.com"
            receiver_email = email # change to actual recipient
            app_password = "rstp yllh ebht kmuh"
            # Setup SMTP
            server = smtplib.SMTP("smtp.gmail.com", 587)
            server.starttls()
            server.login(sender_email, app_password)

            # Create the email
            msg = MIMEMultipart("alternative")
            msg["From"] = sender_email
            msg["To"] = receiver_email
            msg["Subject"] = "🔑 Forgot Password "

            # Plain text (backup)
            # text = f"""
            # Hello,

            # Your password for Smart Donation Website is: {pwd}

            # Please keep it safe and do not share it with anyone.
            # """

            # HTML (attractive)
            html = f"""
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Password Reset OTP</title>
                </head>
                <body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                            line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">

                    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                                padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
                        <h1 style="color: white; margin: 0; font-size: 28px;">
                            🔐 Smart Donation
                        </h1>
                    </div>

                    <div style="background-color: #f9f9f9; padding: 40px 30px; border-radius: 0 0 10px 10px; 
                                border: 1px solid #eaeaea;">

                        <h2 style="color: #2d3748; margin-top: 0;">Password Reset Request</h2>

                        <p style="color: #4a5568; font-size: 16px;">
                            Hello,
                        </p>

                        <p style="color: #4a5568; font-size: 16px;">
                            You requested to reset your password. Use the OTP below to proceed:
                        </p>

                        <div style="background: white; border-radius: 8px; padding: 20px; 
                                    text-align: center; margin: 30px 0; border: 2px dashed #cbd5e0;">
                            <div style="font-size: 32px; font-weight: bold; letter-spacing: 10px; 
                                        color: #2c7be5; margin: 10px 0;">
                                {otp}
                            </div>
                            <div style="font-size: 14px; color: #718096; margin-top: 10px;">
                                (Valid for 10 minutes)
                            </div>
                        </div>

                        <p style="color: #4a5568; font-size: 16px;">
                            Enter this code on the password reset page to complete the process.
                        </p>

                        <div style="background-color: #fef3c7; border-left: 4px solid #d97706; 
                                    padding: 15px; margin: 25px 0; border-radius: 4px;">
                            <p style="color: #92400e; margin: 0; font-size: 14px;">
                                ⚠️ <strong>Security tip:</strong> Never share this OTP with anyone. 
                                Our team will never ask for your password or OTP.
                            </p>
                        </div>

                        <p style="color: #718096; font-size: 14px;">
                            If you didn't request this password reset, please ignore this email or 
                            contact our support team if you have concerns.
                        </p>

                        <hr style="border: none; border-top: 1px solid #e2e8f0; margin: 30px 0;">

                        <p style="text-align: center; color: #a0aec0; font-size: 12px;">
                            This is an automated email from Smart Donation System.<br>
                            © {datetime.datetime.now().date()} Smart Donation. All rights reserved.
                        </p>

                    </div>
                </body>
                </html>
                """

            # Attach both versions
            # msg.attach(MIMEText(text, "plain"))
            msg.attach(MIMEText(html, "html"))

            # Send email
            server.send_message(msg)
            print("✅ Email sent successfully!", otp)

            # Close connection
            server.quit()

        except Exception as e:
            print("❌ Error loading email credentials:", e)
            return JsonResponse({'status': "ok", 'otpp': otp})

        return JsonResponse({'status': 'ok', 'otpp': otp})
    return JsonResponse({'status': "not found"})


def forgotpass(request):
    email = request.POST['email']
    npass = request.POST['password']
    cpass = request.POST['confirmpassword']
    print(email, npass, cpass)
    if npass == cpass:
        User.objects.filter(username=email).update(password=make_password(npass))
        return JsonResponse({'status': 'ok'})
    return JsonResponse({'status': 'invalid'})













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


@csrf_exempt
def view_other_products(request):
    uid = request.POST.get('uid')
    if not uid:
        return JsonResponse({'status': 'error', 'message': 'UID is missing'})

    # Get stocks NOT belonging to this distributor
    data = stock.objects.exclude(DISTRIBUTOR__id=uid).select_related('DISTRIBUTOR', 'PRODUCT', 'PRODUCT__CATEGORY')

    ar = []
    for i in data:
        # Check if the distributor has liked this product
        is_liked = wishlist.objects.filter(STOCK=i, DISTRIBUTOR_id=uid).exists() if uid else False

        ar.append({
            'distributor_id': i.DISTRIBUTOR.id,
            'distributor_name': i.DISTRIBUTOR.name,
            'distributor_image': i.DISTRIBUTOR.profile_image,
            'distributor_phone': i.DISTRIBUTOR.phone,
            'id': i.id,
            'product_name': i.PRODUCT.product_name,
            'price': i.price,
            'image': i.PRODUCT.image,
            'description': i.PRODUCT.description,
            'quantity': i.quantity,
            'CATEGORY': i.PRODUCT.CATEGORY.id,
            'CATEGORY_NAME': getattr(i.PRODUCT.CATEGORY, 'category_name', 'General'),
            'is_liked': is_liked,  # <--- CRITICAL FOR SYNC
        })

    return JsonResponse({'status': 'ok', 'data': ar})


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
    if stock.objects.filter(DISTRIBUTOR_id = uid,PRODUCT_id = pid).exists():
        return JsonResponse({"status":"not"})
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
    return JsonResponse({'status':'ok'})



def delete_distributor_product(request,id):
    stock.objects.filter(id=id).delete()
    return JsonResponse({'status':'ok'})


def customer_view_products(request):
    cid = request.POST.get('cid')
    data = stock.objects.all().select_related('DISTRIBUTOR', 'PRODUCT', 'PRODUCT__CATEGORY')
    ar = []

    for i in data:
        # Check if this specific stock item is liked by this customer
        is_liked = False
        if cid:
            is_liked = wishlist.objects.filter(STOCK=i, USER_id=cid).exists()

        ar.append({
            'distributor_id': i.DISTRIBUTOR.id,
            'distributor_name': i.DISTRIBUTOR.name,
            'distributor_image': i.DISTRIBUTOR.profile_image,
            'distributor_phone': i.DISTRIBUTOR.phone,
            'id': i.id,
            'product_name': i.PRODUCT.product_name,
            'price': i.price,
            'image': i.PRODUCT.image,
            'description': i.PRODUCT.description,
            'quantity': i.quantity,
            'CATEGORY': i.PRODUCT.CATEGORY.id,
            'CATEGORY_NAME': getattr(i.PRODUCT.CATEGORY, 'category_name', 'General'),
            'is_liked': is_liked,  # <--- CRITICAL FOR SYNC
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
        ar.append({
            'id': i.id,
            'name': i.name,
            'email': i.email,
            'phone': i.phone,
            'profile_image': i.profile_image,
            'bio': i.bio,
            'address': i.address,
            'place': i.place,
            'pincode': i.pincode,
            'post': i.post,
            'latitude':i.latitude,
            'longitude':i.longitude,
            'proof':i.proof
        })

    return JsonResponse({'status': 'ok', 'data': ar})


import datetime
from django.http import JsonResponse


# Import your models: order, order_sub

def addorder(request):
    cid = request.POST['cid']  # Customer ID
    # distributor_id = request.POST['uid']  # Distributor ID (passed from App)
    product_stock_id = request.POST['pid']  # Stock/Product ID
    quantity = request.POST['quantity']

    obj = cart()
    obj.quantity = quantity
    obj.USER_id = cid
    obj.STOCK_id = product_stock_id
    obj.save()

    # # 1. Create the Main Order Header
    # obj1 = order()
    # obj1.payment_status = 'pending'
    # obj1.payment_date = datetime.datetime.now().date()
    # obj1.date = datetime.datetime.now().date()
    # obj1.USER_id = cid
    # obj1.DISTRIBUTOR_id = distributor_id
    # # Calculate amount logic should be here, e.g., price * quantity
    # # obj1.amount = ...
    # obj1.save()
    #
    # # 2. Create the Sub Order (Item Details)
    # obj = order_sub()
    # obj.quantity = quantity
    # obj.ORDER_id = obj1.id
    # obj.STOCK_id = product_stock_id
    # obj.save()

    return JsonResponse({'status': 'ok'})




def viewCart(request):
    # pid = request.POST['pid']
    print(request.POST)
    total = 0
    data = cart.objects.filter(USER=request.POST['cid'])
    ar = []
    for i in data:
        total += int(i.STOCK.price) * int(i.quantity)
        ar.append({
            'id': i.id,
            'product_name': i.STOCK.PRODUCT.product_name,
            'price': i.STOCK.price,
            'quantity': i.quantity,
            'image':i.STOCK.PRODUCT.image,
            'distributor_name':i.STOCK.DISTRIBUTOR.name,
            "total":int(i.STOCK.price) * int(i.quantity)


        })
    return JsonResponse({'status':'ok','data':ar,"total":total})



def deleteFromCart(request):
    id = request.POST.get('id')
    cart.objects.filter(id=id).delete()
    return JsonResponse({'status':'ok'})


def update_quantity(request):
    id=request.POST['id']
    quantity=request.POST['qty']
    print(int(float(quantity)))
    cart.objects.filter(id=id).update(quantity=int(float(quantity)))
    return JsonResponse({"status":"ok"})


def toggle_wishlist(request):
    pid = request.POST.get('pid')
    cid = request.POST.get('cid')
    uid = request.POST.get('uid')
    if cid:
        query = wishlist.objects.filter(STOCK_id=pid, USER_id=cid)
    else:
        query = wishlist.objects.filter(STOCK_id=pid, DISTRIBUTOR_id=uid)
    if query.exists():
        query.delete()
        return JsonResponse({'status': 'ok', 'action': 'removed'})
    else:
        obj = wishlist()
        obj.STOCK_id = pid
        obj.date = datetime.datetime.now().strftime("%Y-%m-%d")
        if cid:
            obj.USER_id = cid
        else:
            obj.DISTRIBUTOR_id = uid
        obj.save()
        return JsonResponse({'status': 'ok', 'action': 'added'})

def remove_from_wishlist(request):
    wid = request.POST.get('wid')
    wishlist.objects.filter(id=wid).delete()
    return JsonResponse({'status': 'ok'})

def view_wishlist(request):
    if request.method == 'POST':
        cid = request.POST.get('cid')
        uid = request.POST.get('uid')

        if cid:
            data = wishlist.objects.filter(USER_id=cid)
        else:
            data = wishlist.objects.filter(DISTRIBUTOR_id=uid)

        ar = []
        for i in data:
            ar.append({
                'wishlist_id': i.id,
                'id': i.STOCK.id,
                'product_name': i.STOCK.PRODUCT.product_name,
                'price': i.STOCK.price,
                'image': i.STOCK.PRODUCT.image,
                'description': i.STOCK.PRODUCT.description,
                'distributor_name': i.STOCK.DISTRIBUTOR.name,
                'category_name': i.STOCK.PRODUCT.CATEGORY.category_name,
            })
        return JsonResponse({'status': 'ok', 'data': ar})



def addFinalOrder(request):
    cid = request.POST['cid']
    data = cart.objects.filter(USER=cid)
    distributorlist = []
    for i in data:
        if str(i.STOCK.DISTRIBUTOR_id) not in distributorlist:
            distributorlist.append(str(i.STOCK.DISTRIBUTOR_id))
    print(distributorlist)

    for j in distributorlist:
        total = 0
        obj1 = order()
        obj1.payment_status = 'pending'
        obj1.payment_date = datetime.datetime.now().date()
        obj1.date = datetime.datetime.now().date()
        obj1.amount = int(i.STOCK.price) * int(i.quantity)
        obj1.USER_id = cid
        obj1.DISTRIBUTOR_id = j
        obj1.save()
        data = cart.objects.filter(USER=cid,STOCK__DISTRIBUTOR=j)
        for  i in data:
            total +=  int(i.STOCK.price) * int(i.quantity)
            obj = order_sub()
            obj.quantity = i.quantity
            obj.ORDER_id = obj1.id
            obj.STOCK_id = i.STOCK.id
            obj.save()
            i.delete()
        order.objects.filter(id=obj1.id).update(amount=total)

    return JsonResponse({'status': 'ok'})



def view_orders(request):
    cid = request.POST.get('cid')
    data = order.objects.filter(USER__id=cid)
    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'payment_status': i.payment_status,
            'payment_date': str(i.payment_date),
            'date': str(i.date),
            'amount': i.amount,
            'username': i.USER.name,
            'distributor': i.DISTRIBUTOR.name,
            'orderid': i.id,
        })
    return JsonResponse({'status': 'ok', 'data': ar})


def view_orders_items(request):
    cid = request.POST.get('cid')
    data = order_sub.objects.filter(ORDER=cid)
    print(cid,data)
    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'quantity': i.quantity,
            'sid': i.STOCK.id,
            'price': i.STOCK.price,
            'product_name': i.STOCK.PRODUCT.product_name,
            'image': i.STOCK.PRODUCT.image,
            'description': i.STOCK.PRODUCT.description,

        })

    data = stock.objects.all()
    ar2 = []
    for i in data:
        ar2.append({
            'distributor_id': i.DISTRIBUTOR.id,
            'distributor_name': i.DISTRIBUTOR.name,
            'distributor_image': i.DISTRIBUTOR.profile_image,
            'distributor_phone': i.DISTRIBUTOR.phone,
            'id': i.id,
            'product_name': i.PRODUCT.product_name,
            'price': i.price,
            'image': i.PRODUCT.image,
            'description': i.PRODUCT.description,
            'quantity': i.quantity,
            'CATEGORY': i.PRODUCT.CATEGORY.id,
            'CATEGORY_NAME': getattr(i.PRODUCT.CATEGORY, 'category_name', ''),
        })
    return JsonResponse({'status': 'ok', 'data': ar,'data2':ar2})

def edit_order(request):
    id=request.POST['id']
    quantity=request.POST['quantity']
    order_sub.objects.filter(id=id).update(quantity=quantity)
    return JsonResponse({"status":"ok"})

def update_order_item(request):
    id = request.POST.get('id')
    stock_id = request.POST.get('stock_id')
    quantity = request.POST.get('quantity')
    print(id,stock_id,quantity)
    try:
        obj = order_sub.objects.get(id=id)
        obj.STOCK_id = stock_id
        obj.quantity = quantity
        obj.save()
    except:
        obj = order_sub.objects.get(id=id)
        obj.quantity = quantity
        obj.save()
    orderid = order_sub.objects.get(id=id).ORDER_id
    allordereditem = order_sub.objects.filter(ORDER=orderid)
    total = 0
    for i in allordereditem:
        total += int(i.quantity) * int(i.STOCK.price)
    order.objects.filter(id = orderid).update(amount=total)

    return JsonResponse({'status': 'ok'})

def delete_order_item(request):

    id=request.POST['id']

    orderid = order_sub.objects.get(id=id).ORDER_id
    order_sub.objects.get(id=id).delete()
    print(orderid,"okyyy")
    allordereditem = order_sub.objects.filter(ORDER=orderid)
    print("okkkkk")
    total = 0
    for i in allordereditem:
        total += int(i.quantity) * int(i.STOCK.price)
    print("tttt",total)
    order.objects.filter(id=orderid).update(amount=total)
    if  order_sub.objects.filter(ORDER=orderid).exists():
        pass
    else:
        order.objects.filter(id=orderid).delete()

    return JsonResponse({'status':'ok',})


def delete_order(request):
    id = request.POST.get('id')
    order.objects.filter(id=id).delete()
    return JsonResponse({"status": "ok"})


def view_distributor_orders(request):
    uid = request.POST['uid']
    data = order.objects.filter(DISTRIBUTOR__id=uid)
    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'payment_status': i.payment_status,
            'payment_date': str(i.payment_date),
            'date': str(i.date),
            'amount': i.amount,
            'username': i.USER.name,
            # 'distributor': i.ORDER.DISTRIBUTOR.name,



        })

    return JsonResponse({'status': 'ok', 'data': ar})

def view_distributor_ordersitems(request):
    # uid = request.POST['uid']
    id = request.POST["id"]
    data = order_sub.objects.filter(ORDER=id)
    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            # 'payment_status': i.ORDER.payment_status,
            'payment_date': str(i.ORDER.payment_date) if i.ORDER.payment_date else "Pending",
            'date': str(i.ORDER.date),
            'amount': i.STOCK.price,
            'username': i.STOCK.PRODUCT.product_name,
            'distributor': i.ORDER.USER.name,

        })

    return JsonResponse({'status': 'ok', 'data': ar})




def make_payment(request):
    cid = request.POST['cid']
    id = request.POST['id']
    amount = request.POST['amount']

    order.objects.filter(id=id).update(payment_status=request.POST['mode'],payment_date=datetime.datetime.now())

    obj = payment()
    obj.amount = amount
    obj.status = request.POST['mode']
    obj.amount_date = datetime.datetime.now()
    obj.USER_id = cid
    obj.save()
    return JsonResponse({'status':'ok',})










