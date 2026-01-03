import os
from datetime import datetime

from django.conf import settings
from django.contrib.auth import authenticate, login
from django.contrib.auth.decorators import login_required
from django.contrib.auth.hashers import make_password, check_password
from django.contrib.auth.models import User, Group
from django.core.files.storage import FileSystemStorage
from django.http import HttpResponse, JsonResponse
from django.contrib import messages
from django.contrib.auth import update_session_auth_hash
from django.shortcuts import render, redirect, get_object_or_404
from difflib import get_close_matches
import cv2



import google.generativeai as genai
from PIL import Image
import io


def get_new_filename():
    dt=datetime.now().strftime("%Y%m%d_%H%M%S")+".jpg"
    return dt

#   admin@gmail.com     superuser

# Create your views here
from django.views.decorators.csrf import csrf_exempt

from my_app.models import category, distributor, review, feedback, customer, product, stock, order_sub, order, payment, \
    cart, wishlist, DistributorCustomerLink

print(make_password("password"))

def log(request):
    return render(request, 'login.html')


def logout(request):
    return redirect("/")



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
    obj.review_date = datetime.now().date()
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
#     obj.feedback_date = datetime.now().date()
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
        obj.feedback_date = datetime.now().date()

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


    try:
        uid = request.POST.get('uid')

        # 1. Query the Link table instead of the Order table
        # We use select_related('CUSTOMER') to fetch customer details in one go (optimization)
        links = DistributorCustomerLink.objects.filter(DISTRIBUTOR_id=uid).select_related('CUSTOMER')

        ar = []
        for link in links:
            # 'link.CUSTOMER' points to the actual customer object
            i = link.CUSTOMER

            ar.append({
                'id': i.id,
                'cid': i.id,  # Included for compatibility with your Flutter Joke model
                'name': i.name,
                'email': i.email,
                'phone': i.phone,
                'profile_image': i.profile_image,
                'address': i.address,
                'place': i.place,
                'pincode': i.pincode,
                'post': i.post,
                'bio': i.bio
            })

        return JsonResponse({'status': 'ok', 'data': ar})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})



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
            sender_email = "snap2bill@gmail.com"
            receiver_email = email # change to actual recipient
            app_password = "zfpm hiry mqgm rzer"
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



            logo_url = "https://lh3.googleusercontent.com/d/1bxyWDmDw3-p2xNIAP5wSAGgZPx1TtzBj"


            html = f"""
            <!DOCTYPE html>
            <html>
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>Snap2Bill Verification</title>
            </head>
            <body style="margin:0; padding:0; background-color:#F0F4F8; font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">

              <table width="100%" border="0" cellspacing="0" cellpadding="0" style="background-color:#F0F4F8; padding:40px 10px;">
                <tr>
                  <td align="center">

                    <table width="100%" border="0" cellspacing="0" cellpadding="0" style="max-width:500px; background-color:#ffffff; border-radius:24px; overflow:hidden; box-shadow: 0 10px 25px rgba(0,0,0,0.05);">

                      <tr>
                        <td align="center" style="padding:40px 0 20px 0;">
                          <img src="{logo_url}" alt="Snap2Bill Logo" width="80" style="display:block; margin-bottom:15px; border:0;">

                          <h1 style="margin:0; font-size:24px; color:#1E293B; letter-spacing:-0.5px;">
                            Snap<span style="color:#2563EB;">2</span>Bill
                          </h1>
                        </td>
                      </tr>

                      <tr>
                        <td style="padding:0 40px 40px 40px;">
                          <div style="text-align:center;">
                            <h2 style="color:#1E293B; font-size:22px; margin-bottom:10px;">Verify your identity</h2>
                            <p style="color:#64748B; font-size:15px; line-height:1.6; margin-bottom:30px;">
                              Hello,<br>
                              Use the code below to securely reset your password. This code is unique to your request.
                            </p>
                          </div>

                          <div style="background-color:#F8FAFC; border:1px solid #E2E8F0; border-radius:16px; padding:25px; text-align:center; margin-bottom:30px;">
                            <span style="display:block; color:#94A3B8; font-size:12px; font-weight:bold; letter-spacing:1px; margin-bottom:10px; text-transform:uppercase;">Verification Code</span>
                            <span style="font-family:'Courier New', Courier, monospace; font-size:38px; font-weight:bold; color:#2563EB; letter-spacing:8px; margin-left:8px;">
                              {otp}
                            </span>
                          </div>

                          <div style="text-align:center; margin-bottom:30px;">
                            <p style="color:#64748B; font-size:14px; margin:0;">
                               This code expires in <strong style="color:#F59E0B;">10 minutes</strong>.
                            </p>
                          </div>

                          <div style="height:1px; background-color:#E2E8F0; margin-bottom:30px;"></div>

                          <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                              <td style="background-color:#FFFBEB; border-radius:12px; padding:15px;">
                                <p style="margin:0; font-size:13px; color:#B45309; line-height:1.5;">
                                  <strong>Security Reminder:</strong> Never share this code with anyone. Snap2Bill employees will never ask for this code over the phone or via email.
                                </p>
                              </td>
                            </tr>
                          </table>
                        </td>
                      </tr>

                      <tr>
                        <td align="center" style="padding:0 40px 40px 40px;">
                          <p style="color:#94A3B8; font-size:12px; margin:0;">
                            If you didn't request this, you can safely ignore this email.
                          </p>
                          <p style="color:#CBD5E1; font-size:11px; margin-top:20px;">
                            © {datetime.now().year} Snap2Bill Inc. <br>
                            Smart Billing Solutions
                          </p>
                        </td>
                      </tr>

                    </table>
                  </td>
                </tr>
              </table>

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
    fname=get_new_filename()
    fullpath=r"D:\snap2bill\snap2bill\media\\"+fname
    fs=FileSystemStorage()
    image=fs.save(fullpath,img)
    # price = request.POST['price']
    quantity = request.POST['quantity']
    description = request.POST['description']
    category = request.POST['category']
    # obj = product(product_name=product_name,image=fs.url(image),price=price,quantity=quantity,description=description,CATEGORY_id=category)
    obj = product(product_name=product_name,image="/media/"+fname,quantity=quantity,description=description,CATEGORY_id=category)
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


def view_other_products(request):
    uid = request.POST.get('uid')
    dist = distributor.objects.get(id=uid)

    data = stock.objects.exclude(DISTRIBUTOR=dist)
    ar = []

    for i in data:
        liked = wishlist.objects.filter(
            STOCK=i,
            DISTRIBUTOR=dist,
            USER__isnull=True
        ).exists()

        ar.append({
            'id': i.id,
            'product_name': i.PRODUCT.product_name,
            'price': i.price,
            'image': i.PRODUCT.image,
            'description': i.PRODUCT.description,
            'CATEGORY': i.PRODUCT.CATEGORY.id,
            'CATEGORY_NAME': i.PRODUCT.CATEGORY.category_name,
            'distributor_id': i.DISTRIBUTOR.id,
            'distributor_name': i.DISTRIBUTOR.name,
            'distributor_image': i.DISTRIBUTOR.profile_image,
            'distributor_phone': i.DISTRIBUTOR.phone,
            'is_liked': liked,   # 🔥 THIS LINE
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
    user = customer.objects.get(id=cid) if cid else None

    data = stock.objects.all()
    ar = []

    for i in data:
        liked = False
        if user:
            liked = wishlist.objects.filter(
                STOCK=i,
                USER=user,
                DISTRIBUTOR__isnull=True
            ).exists()

        ar.append({
            'id': i.id,
            'product_name': i.PRODUCT.product_name,
            'price': i.price,
            'image': i.PRODUCT.image,
            'description': i.PRODUCT.description,
            'CATEGORY': i.PRODUCT.CATEGORY.id,
            'CATEGORY_NAME': i.PRODUCT.CATEGORY.category_name,
            'distributor_id': i.DISTRIBUTOR.id,
            'distributor_name': i.DISTRIBUTOR.name,
            'distributor_image': i.DISTRIBUTOR.profile_image,
            'distributor_phone': i.DISTRIBUTOR.phone,
            'is_liked': liked,   # 🔥 THIS LINE
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
    try:
        cid = request.POST.get('cid')
        links = DistributorCustomerLink.objects.filter(CUSTOMER_id=cid).select_related('DISTRIBUTOR')
        ar = []
        for link in links:
            i = link.DISTRIBUTOR
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
                'latitude': i.latitude,
                'longitude': i.longitude,
            })

        return JsonResponse({'status': 'ok', 'data': ar})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})


@csrf_exempt
def get_product_details(request):
    pid = request.POST.get('pid')
    try:
        # Fetching from Stock model since that's where the price and current stock are
        i = stock.objects.get(id=pid)
        data = {
            'id': i.id,
            'product_name': i.PRODUCT.product_name,
            'price': i.price,
            'image': i.PRODUCT.image,
            'description': i.PRODUCT.description,
            'stock_quantity': i.quantity,
            'category': i.PRODUCT.CATEGORY.category_name,
            'distributor': i.DISTRIBUTOR.name
        }
        return JsonResponse({'status': 'ok', 'data': data})
    except stock.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Product not found'})


@csrf_exempt
def addorder(request):
    cid = request.POST.get('cid')
    product_stock_id = request.POST.get('pid')
    quantity = int(request.POST.get('quantity', 1))

    # Check if item already in cart
    cart_item = cart.objects.filter(STOCK_id=product_stock_id, USER_id=cid).first()

    if cart_item:
        cart_item.quantity = int(cart_item.quantity) + quantity
        cart_item.save()
    else:
        obj = cart()
        obj.quantity = quantity
        obj.USER_id = cid
        obj.STOCK_id = product_stock_id
        obj.save()

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

    if not pid:
        return JsonResponse({'status': 'error', 'msg': 'pid missing'})

    stock_obj = stock.objects.get(id=pid)

    # ================= CUSTOMER =================
    if cid and not uid:
        print("👉 CUSTOMER WISHLIST")
        user = customer.objects.get(id=cid)

        qs = wishlist.objects.filter(
            STOCK=stock_obj,
            USER=user,
            DISTRIBUTOR__isnull=True
        )

        if qs.exists():
            qs.delete()
            return JsonResponse({'status': 'ok', 'action': 'removed'})
        else:
            wishlist.objects.create(
                STOCK=stock_obj,
                USER=user,
                DISTRIBUTOR=None,
                date=str(datetime.now())
            )
            return JsonResponse({'status': 'ok', 'action': 'added'})

    # ================= DISTRIBUTOR =================
    if uid and not cid:
        print("👉 DISTRIBUTOR WISHLIST")
        dist = distributor.objects.get(id=uid)

        qs = wishlist.objects.filter(
            STOCK=stock_obj,
            DISTRIBUTOR=dist,
            USER__isnull=True
        )

        if qs.exists():
            qs.delete()
            return JsonResponse({'status': 'ok', 'action': 'removed'})
        else:
            wishlist.objects.create(
                STOCK=stock_obj,
                DISTRIBUTOR=dist,
                USER=None,
                date=str(datetime.now())
            )
            return JsonResponse({'status': 'ok', 'action': 'added'})

    return JsonResponse({'status': 'error', 'msg': 'invalid request'})

def remove_from_wishlist(request):
    wid = request.POST.get('wid')
    cid = request.POST.get('cid')
    uid = request.POST.get('uid')

    if not wid:
        return JsonResponse({'status': 'error', 'msg': 'wid missing'})

    # CUSTOMER
    if cid and not uid:
        wishlist.objects.filter(
            id=wid,
            USER_id=cid,
            DISTRIBUTOR__isnull=True
        ).delete()

    # DISTRIBUTOR
    elif uid and not cid:
        wishlist.objects.filter(
            id=wid,
            DISTRIBUTOR_id=uid,
            USER__isnull=True
        ).delete()

    return JsonResponse({'status': 'ok'})

def view_wishlist(request):
    cid = request.POST.get('cid')
    uid = request.POST.get('uid')

    # CUSTOMER
    if cid and not uid:
        data = wishlist.objects.filter(
            USER__id=cid,
            DISTRIBUTOR__isnull=True
        )

    # DISTRIBUTOR
    elif uid and not cid:
        data = wishlist.objects.filter(
            DISTRIBUTOR__id=uid,
            USER__isnull=True
        )

    else:
        data = []

    ar = []
    for i in data:
        ar.append({
            'wishlist_id': i.id,
            'id': i.STOCK.id,
            'product_name': i.STOCK.PRODUCT.product_name,
            'price': i.STOCK.price,
            'image': i.STOCK.PRODUCT.image,
            'category_name': i.STOCK.PRODUCT.CATEGORY.category_name,
            'distributor_name': i.STOCK.DISTRIBUTOR.name,
        })

    return JsonResponse({'status': 'ok', 'data': ar})




def addFinalOrder(request):
    try:
        cid = request.POST['cid']
        # Fetch all items in the customer's cart
        cart_items = cart.objects.filter(USER_id=cid)

        if not cart_items.exists():
            return JsonResponse({'status': 'error', 'message': 'Cart is empty'})

        # Get a list of unique distributor IDs from the cart items
        distributor_list = []
        for item in cart_items:
            dist_id = str(item.STOCK.DISTRIBUTOR_id)
            if dist_id not in distributor_list:
                distributor_list.append(dist_id)

        # Iterate through each distributor to create separate orders
        for d_id in distributor_list:

            # --- PERMANENT LINK LOGIC ---
            # This creates a record in DistributorCustomerLink if it doesn't exist.
            # This is why the customer will never disappear from the distributor's list.
            DistributorCustomerLink.objects.get_or_create(
                DISTRIBUTOR_id=d_id,
                CUSTOMER_id=cid
            )

            # Create the main Order header for this distributor
            new_order = order()
            new_order.USER_id = cid
            new_order.DISTRIBUTOR_id = d_id
            new_order.payment_status = 'pending'
            new_order.payment_date = "pending"  # or datetime.now().date()
            new_order.date = datetime.now().date()
            new_order.amount = 0  # Will update this after calculating total
            new_order.save()

            # Filter cart items belonging to THIS specific distributor
            specific_dist_items = cart.objects.filter(USER_id=cid, STOCK__DISTRIBUTOR_id=d_id)

            order_total = 0
            for c_item in specific_dist_items:
                # Calculate subtotal for this item
                item_price = float(c_item.STOCK.price)
                item_qty = int(c_item.quantity)
                order_total += (item_price * item_qty)

                # Create Order Sub entry (the specific product in the order)
                sub_obj = order_sub()
                sub_obj.ORDER_id = new_order.id
                sub_obj.STOCK_id = c_item.STOCK.id
                sub_obj.quantity = item_qty
                sub_obj.save()

                # Remove the item from the cart as it is now an order
                c_item.delete()

            # Update the main order with the correct total amount
            new_order.amount = order_total
            new_order.save()

        return JsonResponse({'status': 'ok'})

    except Exception as e:
        print(f"Error in addFinalOrder: {e}")
        return JsonResponse({'status': 'error', 'message': str(e)})


def view_orders(request):
    cid = request.POST.get('cid')  # Customer ID
    did = request.POST.get('did')  # NEW: Distributor ID filter

    filters = {'USER_id': cid}

    # If customer clicked a specific distributor, filter orders for that distributor
    if did and did not in ["", "null", "None"]:
        filters['DISTRIBUTOR_id'] = did

    data = order.objects.filter(**filters).select_related('DISTRIBUTOR').order_by('-id')

    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'payment_status': i.payment_status,
            'payment_date': str(i.payment_date) if i.payment_date else "---",
            'date': str(i.date),
            'amount': i.amount,
            'distributor': i.DISTRIBUTOR.name,  # Show distributor name instead of username
            'orderid': i.id,
        })
    return JsonResponse({'status': 'ok', 'data': ar})


def view_orders_items(request):
    order_id = request.POST.get('oid')
    items_data = order_sub.objects.filter(ORDER=order_id)

    ar = []
    for i in items_data:
        ar.append({
            'id': i.id,
            'quantity': i.quantity,
            'sid': i.STOCK.id,
            'price': i.STOCK.price,
            'product_name': i.STOCK.PRODUCT.product_name,
            'image': i.STOCK.PRODUCT.image,
            'description': i.STOCK.PRODUCT.description,
        })

    try:
        parent_order = order.objects.get(id=order_id)
        distributor_id = parent_order.DISTRIBUTOR_id
        stock_data = stock.objects.filter(DISTRIBUTOR_id=distributor_id)
    except order.DoesNotExist:
        stock_data = []

    ar2 = []
    for i in stock_data:
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

    return JsonResponse({
        'status': 'ok',
        'data': ar,
        'data2': ar2
    })


def edit_order(request):
    id = request.POST['id']
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
    uid = request.POST.get('uid')
    cid = request.POST.get('cid')
    filters = {'DISTRIBUTOR_id': uid}
    if cid and cid not in ["", "null", "None"]:
        filters['USER_id'] = cid
    data = order.objects.filter(**filters).select_related('USER').order_by('-id')
    ar = []
    for i in data:
        p_date = str(i.payment_date)
        if p_date in ["None", "null", "pending", ""]:
            p_date = "Not Paid Yet"
        ar.append({
            'id': i.id,
            'payment_status': i.payment_status,
            'payment_date': p_date,
            'date': str(i.date),
            'amount': i.amount,
            'username': i.USER.name,
        })
    return JsonResponse({'status': 'ok', 'data': ar})


def view_distributor_ordersitems(request):
    id = request.POST["id"]
    data = order_sub.objects.filter(ORDER=id)
    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'quatity':i.quantity,
            'image': i.STOCK.PRODUCT.image,
            'amount': i.STOCK.price,
            'product_name': i.STOCK.PRODUCT.product_name,
            'username': i.ORDER.USER.name,

        })

    return JsonResponse({'status': 'ok', 'data': ar})




def make_payment(request):
    cid = request.POST['cid']
    id = request.POST['id']
    amount = request.POST['amount']

    order.objects.filter(id=id).update(payment_status=request.POST['mode'],payment_date=datetime.now())

    obj = payment()
    obj.amount = amount
    obj.status = request.POST['mode']
    obj.amount_date = datetime.now()
    obj.USER_id = cid
    obj.save()
    return JsonResponse({'status':'ok',})






def compare_images(img1_path, img2_path):
    img1 = cv2.imread(img1_path)
    img2 = cv2.imread(img2_path)

    if img1 is None or img2 is None:
        return -1

    img1 = cv2.resize(img1, (300, 300))
    img2 = cv2.resize(img2, (300, 300))

    hist1 = cv2.calcHist([img1], [0, 1, 2], None, [8, 8, 8], [0, 256, 0, 256, 0, 256])
    hist2 = cv2.calcHist([img2], [0, 1, 2], None, [8, 8, 8], [0, 256, 0, 256, 0, 256])

    cv2.normalize(hist1, hist1)
    cv2.normalize(hist2, hist2)

    score = cv2.compareHist(hist1, hist2, cv2.HISTCMP_CORREL)
    return score

def scanItem(request):

    if request.method != "POST":
        return JsonResponse({'status': 'error', 'message': 'Invalid request'})

    # =========================
    # 1. Distributor stock
    # =========================
    uid = request.POST.get('uid')
    if not uid:
        return JsonResponse({'status': 'error', 'message': 'uid missing'})

    allproduct = stock.objects.filter(DISTRIBUTOR_id=uid)

    if not allproduct.exists():
        return JsonResponse({'status': 'error', 'message': 'No stock found'})

    # =========================
    # 2. Uploaded image
    # =========================
    if 'image' not in request.FILES:
        return JsonResponse({'status': 'error', 'message': 'Image missing'})

    fname=get_new_filename()
    full_path=r"D:\snap2bill\snap2bill\media\\" + fname
    image_file = request.FILES['image']
    fs = FileSystemStorage()
    saved_name = fs.save(full_path, image_file)

    # scanned_image_path = os.path.normpath(fs.path(saved_name))
    scanned_image_path = full_path
    print("Scanned image:", scanned_image_path)

    # =========================
    # 3. Compare with stock images
    # =========================
    best_score = -1
    matched_stock = None

    for item in allproduct:

        if not item.PRODUCT.image:
            continue

        product_image_path = r"D:\snap2bill\snap2bill\media\\"+item.PRODUCT.image.split('/')[-1]

        print("Comparing with:", product_image_path)

        if not os.path.exists(product_image_path):
            print("❌ Image not found")
            continue

        score = compare_images(scanned_image_path, product_image_path)
        print(item.PRODUCT.product_name, "score:", score)

        if score > best_score:
            best_score = score
            matched_stock = item

    # =========================
    # 4. Threshold + response
    # =========================
    print("Best match\n***************")
    print(best_score, matched_stock)
    if matched_stock and best_score >= 0.6:
        return JsonResponse({
            'status': 'ok',
            'stock_id': matched_stock.id,
            'product_name': matched_stock.PRODUCT.product_name,
            'match_score': round(best_score, 2)
        })

    return JsonResponse({
        'status': 'not_found',
        'match_score': round(best_score, 2)
    })


# def scanItem(request):
#
#     if request.method != "POST":
#         return JsonResponse({'status': 'error', 'message': 'Invalid request'})
#
#     # ============================
#     # 1. Get distributor stock
#     # ============================
#     uid = request.POST.get('uid')
#     if not uid:
#         return JsonResponse({'status': 'error', 'message': 'uid missing'})
#
#     allproduct = stock.objects.filter(DISTRIBUTOR_id=uid)
#
#     if not allproduct.exists():
#         return JsonResponse({'status': 'error', 'message': 'No stock found'})
#
#     # ============================
#     # 2. Save uploaded image
#     # ============================
#     if 'image' not in request.FILES:
#         return JsonResponse({'status': 'error', 'message': 'Image missing'})
#
#     image_file = request.FILES['image']
#     fs = FileSystemStorage()
#     saved_path = fs.save(image_file.name, image_file)
#     image_path = fs.path(saved_path)
#
#     # ============================
#     # 3. Load image & convert to bytes
#     # ============================
#     image = Image.open(image_path)
#     image_bytes = io.BytesIO()
#     image.save(image_bytes, format="JPEG")
#     image_bytes = image_bytes.getvalue()
#
#     # ============================
#     # 4. Gemini Configuration
#     # ============================
#     genai.configure(api_key="AIzaSyAduEHNgfrIKbihOtLOAUJf9NsoXsw7MW0")
#
#     model = genai.GenerativeModel("models/gemini-2.5-flash-lite")
#
#     response = model.generate_content(
#         [
#             "Identify the main product in this image. "
#             "Return ONLY product name in 1–3 words. "
#             "No sentence, no punctuation.",
#             {"mime_type": "image/jpeg", "data": image_bytes}
#         ],
#         generation_config={
#             "temperature": 0.2,
#             "max_output_tokens": 50
#         }
#     )
#
#     detected_object = response.text.strip().lower()
#     print("Detected object:", detected_object)
#
#     # ============================
#     # 5. Match with stock products
#     # ============================
#     stock_names = {}
#     for item in allproduct:
#         name = item.PRODUCT.product_name.lower()
#         stock_names[name] = item
#
#     matched_stock = None
#
#     # Direct contains match
#     for name, item in stock_names.items():
#         if detected_object in name or name in detected_object:
#             matched_stock = item
#             break
#
#     # Fuzzy match if direct not found
#     if not matched_stock:
#         close = get_close_matches(detected_object, stock_names.keys(), n=1, cutoff=0.6)
#         if close:
#             matched_stock = stock_names[close[0]]
#
#     # ============================
#     # 6. Response
#     # ============================
#     if matched_stock:
#         return JsonResponse({
#             'status': 'ok',
#             'stock_id': matched_stock.id,
#             'product_name': matched_stock.PRODUCT.name,
#             'detected_object': detected_object
#         })
#     else:
#         return JsonResponse({
#             'status': 'not_found',
#             'detected_object': detected_object
#         })



