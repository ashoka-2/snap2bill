import os
from datetime import datetime
from collections import defaultdict
from django.contrib.auth import authenticate, login, update_session_auth_hash
from django.contrib.auth.decorators import login_required
from django.contrib.auth.hashers import make_password, check_password
from django.contrib.auth.models import User, Group
from django.core.files.storage import FileSystemStorage
from django.http import HttpResponse, JsonResponse
from django.contrib import messages
from django.shortcuts import render, redirect, get_object_or_404
from django.db.models import Q, Count
from django.contrib.auth import logout as auth_logout
from dotenv import load_dotenv
load_dotenv()

import cv2
from django.views.decorators.csrf import csrf_exempt
import json
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
# from io import BytesIO
from django.core.files.base import ContentFile
from django.utils import timezone
from PIL import Image
import pillow_heif
import io
import google.generativeai as genai


pillow_heif.register_heif_opener()
def compress_image(image_file):
    try:
        original_name = image_file.name
        img = Image.open(image_file)
        if img.mode != 'RGB':
            img = img.convert('RGB')
        img.thumbnail((1000, 1000))
        buffer = io.BytesIO()
        img.save(buffer, format="JPEG", quality=60, optimize=True)
        new_filename = original_name.rsplit('.', 1)[0] + ".jpg"
        return ContentFile(buffer.getvalue(), name=new_filename)

    except Exception as e:
        print(f"Compression Error for {image_file.name}: {e}")
        return image_file





def get_new_filename():
    dt=datetime.now().strftime("%Y%m%d_%H%M%S")+".jpg"
    return dt




from my_app.models import category, distributor, review, feedback, customer, product, stock, order_sub, order, payment, \
    cart, wishlist, DistributorCustomerLink, unit, recently_viewed, location

print(make_password("password"))



def log(request):
    return render(request, 'login.html')


def logout(request):
    auth_logout(request)
    return redirect("/")


def login_post(request):
    un = request.POST.get('username')
    psw = request.POST.get('password')

    # User ko authenticate karo
    data = authenticate(request, username=un, password=psw)

    if data is not None:
        # Check karo ki kya wo Admin (superuser) hai
        if data.is_superuser:
            login(request, data)
            return redirect('/admin_home')
        else:
            # Agar koi customer/distributor admin portal se login try kare
            messages.error(request, "Access Denied! Only admins can login here.")
            return redirect('/')  # Wapis login page par bhej do
    else:
        # Agar username ya password galat ho
        messages.error(request, "Invalid Username or Password.")
        return redirect('/')  # Wapis login page par bhej do






@login_required(login_url='/')
def change_password(request):
    return render(request, 'changePassword.html')


@login_required(login_url='/')
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
    if request.method == "POST":
        newpass = request.POST.get('newpassword')
        confirmpass = request.POST.get('confirmpassword')

        if newpass != confirmpass:
            messages.error(request, "Passwords do not match!")
            return redirect('change_password_page')

        try:
            # Check if session ID exists
            if 'fid' in request.session:
                obj = User.objects.get(id=request.session['fid'])
                obj.set_password(newpass)
                obj.save()

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



@login_required(login_url='/')
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

@login_required(login_url='/')
def admin_setting(request):
    return render(request,'admin/settingpage.html')

@login_required(login_url='/')
def admin_verify(request):
    distributordata = distributor.objects.filter(status='pending')
    return render(request, 'admin/admin_verify.html',{'distributordata':distributordata})

@login_required(login_url='/')
def accept_distributor(request,id):
    distributor.objects.filter(id=id).update(status='approve')
    return HttpResponse("<script>window.location='/admin_verify'</script>")

@login_required(login_url='/')
def reject_distributor(request,id):
    distributor.objects.filter(id=id).update(status='reject')
    return HttpResponse("<script>window.location='/admin_verify'</script>")

@login_required(login_url='/')
def admin_verified(request):
    distributordata = distributor.objects.filter(status='approve')
    return render(request, 'admin/admin_verified.html',{'distributordata':distributordata})

@login_required(login_url='/')
def admin_viewcustomer(request):
    customerdata = customer.objects.all()
    return render(request, 'admin/admin_viewcustomer.html',{'customerdata':customerdata})

@login_required(login_url='/')
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


@login_required(login_url='/')
def admin_category(request):
    data = category.objects.all()
    return render(request, 'admin/admin_category.html', {'data': data})

@login_required(login_url='/')
def admin_add_category(request):
    return render(request, 'admin/add_category.html')

@login_required(login_url='/')
def add_category_post(request):
    category_name = request.POST['Category']
    obj = category(category_name=category_name)
    obj.save()
    messages.success(request, f"Category '{category_name}' added successfully!")
    return redirect('/admin_category')

@login_required(login_url='/')
def edit_category(request, id):
    data = get_object_or_404(category, id=id)
    return render(request, 'admin/edit_category.html', {'data': data})

@login_required(login_url='/')
def edit_category_post(request, id):
    cat = request.POST['Category']
    category.objects.filter(id=id).update(category_name=cat)
    messages.success(request, f"Category updated to '{cat}' successfully!")
    return redirect('/admin_category')

@login_required(login_url='/')
def delete_category(request, id):
    obj=category.objects.get(id=id)
    name = obj.category_name
    obj.delete()
    messages.error(request, f"Category '{name}' deleted.")
    return redirect('/admin_category')

@login_required(login_url='/')
def manage_units(request):
    # --- HANDLE ADDING/EDITING ---
    if request.method == "POST":
        unit_id = request.POST.get('id')  # If this exists, we are editing
        u_name = request.POST.get('unit_name')

        if unit_id:
            # Edit existing unit
            unit.objects.filter(id=unit_id).update(unit_name=u_name)
            messages.success(request, "Unit Updated!")
        else:
            # Add new unit
            unit.objects.create(unit_name=u_name)
            messages.success(request, "Unit Added!")

        return redirect('/manage_units')

    # --- HANDLE VIEWING ---
    data = unit.objects.all().order_by('unit_name')
    return render(request, 'admin/manage_units.html', {'data': data})


@login_required(login_url='/')
def delete_unit(request, id):
    unit.objects.filter(id=id).delete()
    messages.error(request, "Unit Deleted.")
    return redirect('/manage_units')


def view_units(request):
    try:
        # 1. Fetch all unit objects from the database
        data = unit.objects.all().order_by('unit_name')

        # 2. Convert the QuerySet into a list of dictionaries
        ar = []
        for i in data:
            ar.append({
                'id': i.id,
                'unit_name': i.unit_name,
            })

        # 3. Return the data as JSON
        return JsonResponse({'status': 'ok', 'data': ar})

    except Exception as e:
        # Return an error message if something goes wrong
        return JsonResponse({'status': 'error', 'message': str(e)})




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

    profile_image = compress_image(request.FILES['file'])
    proof = compress_image(request.FILES['file1'])
    fs = FileSystemStorage()
    path = fs.save(profile_image.name, profile_image)
    path1 = fs.save(proof.name, proof)

    # POST data fetch kar rahe hain
    name = request.POST['name']
    email = request.POST['email']
    phone = request.POST['phone']
    password = request.POST['password']
    bio = request.POST['bio']
    latitude = request.POST['latitude']
    longitude = request.POST['longitude']

    address = request.POST['address']
    pincode = request.POST['pincode']
    place = request.POST['place']
    post = request.POST['post']

    loc_obj = location.objects.create(
        address=address,
        place=place,
        pincode=pincode,
        post=post
    )

    obj = User()
    obj.username = email
    obj.password = make_password(password)
    obj.save()
    obj.groups.add(Group.objects.get(name='distributor'))

    ob = distributor()
    ob.profile_image = fs.url(path)
    ob.name = name
    ob.email = email
    ob.phone = phone
    ob.bio = bio
    ob.latitude = latitude
    ob.longitude = longitude
    ob.proof = fs.url(path1)
    ob.status = 'pending'

    ob.LOCATION = loc_obj
    ob.LOGIN = obj
    ob.save()

    return JsonResponse({'status': 'ok'})


def distributor_view_profile(request):
    uid = request.POST['uid']

    data = distributor.objects.select_related('LOCATION').filter(id=uid).annotate(
        customer_count=Count('distributorcustomerlink')
    )

    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'name': i.name,
            'email': i.email,
            'phone': i.phone,
            'profile_image': i.profile_image,
            'bio': i.bio,
            'address': i.LOCATION.address if i.LOCATION else "",
            'place': i.LOCATION.place if i.LOCATION else "",
            'pincode': i.LOCATION.pincode if i.LOCATION else "",
            'post': i.LOCATION.post if i.LOCATION else "",
            'latitude': i.latitude,
            'longitude': i.longitude,
            'proof': i.proof,
            'customer_count': i.customer_count
        })

    return JsonResponse({'status': 'ok', 'data': ar})


def edit_distributor_profile(request):
    uid = request.POST['uid']

    # 🚀 Pehle distributor object fetch karein taaki uski location mil sake
    dist_obj = get_object_or_404(distributor, id=uid)

    if 'file' in request.FILES:
        profile_image = compress_image(request.FILES['file'])
        fs = FileSystemStorage()
        path = fs.save(profile_image.name, profile_image)
        dist_obj.profile_image = fs.url(path)

    if 'file1' in request.FILES:
        proof = compress_image(request.FILES['file1'])
        fs = FileSystemStorage()
        path1 = fs.save(proof.name, proof)
        dist_obj.proof = fs.url(path1)

    # Distributor table ke fields
    dist_obj.name = request.POST['name']
    dist_obj.phone = request.POST['phone']
    dist_obj.bio = request.POST['bio']
    dist_obj.latitude = request.POST['latitude']
    dist_obj.longitude = request.POST['longitude']
    dist_obj.save()

    # 🚀 STEP: Linked Location table ko update karein
    if dist_obj.LOCATION:
        loc = dist_obj.LOCATION
        loc.address = request.POST['address']
        loc.pincode = request.POST['pincode']
        loc.place = request.POST['place']
        loc.post = request.POST['post']
        loc.save()

    return JsonResponse({'status': 'ok'})


def distributor_view_customer(request):
    try:
        uid = request.POST.get('uid')
        # 🚀 CUSTOMER__LOCATION tak join kiya taaki address details mil sakein
        links = DistributorCustomerLink.objects.filter(DISTRIBUTOR_id=uid).select_related('CUSTOMER__LOCATION')

        ar = []
        for link in links:
            i = link.CUSTOMER
            data2 = order.objects.filter(order_type="offline_pending", USER_id=i.id, DISTRIBUTOR_id=uid)
            order_id = data2[0].id if data2.exists() else 0

            ar.append({
                'id': i.id,
                'cid': i.id,
                'name': i.name,
                'email': i.email,
                'phone': i.phone,
                'profile_image': i.profile_image,
                # 🚀 Accessing from LOCATION table
                'address': i.LOCATION.address if i.LOCATION else "",
                'place': i.LOCATION.place if i.LOCATION else "",
                'pincode': i.LOCATION.pincode if i.LOCATION else "",
                'post': i.LOCATION.post if i.LOCATION else "",
                'bio': i.bio,
                'oid': order_id
            })

        return JsonResponse({'status': 'ok', 'data': ar})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})




def distributor_view_distributor(request):
    data = distributor.objects.select_related('LOCATION').all()

    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'name': i.name,
            'email': i.email,
            'phone': i.phone,
            'profile_image': i.profile_image,
            'bio': i.bio,
            'address': i.LOCATION.address if i.LOCATION else "",
            'place': i.LOCATION.place if i.LOCATION else "",
            'pincode': i.LOCATION.pincode if i.LOCATION else "",
            'post': i.LOCATION.post if i.LOCATION else "",
            'latitude': i.latitude,
            'longitude': i.longitude,
            'proof': i.proof
        })

    return JsonResponse({'status': 'ok', 'data': ar})







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
            app_password = os.getenv("EMAIL_APP_PASSWORD")
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












@login_required(login_url='/')
def view_product(request):
    productdata = product.objects.all()
    return render(request, 'admin/view_product.html', {'productdata': productdata})

@login_required(login_url='/')
def add_product(request):
    categorydtata = category.objects.all()
    return render(request,"admin/add_product.html",{'categorydata':categorydtata})


@login_required(login_url='/')
def add_product_post(request):
    product_name = request.POST['product_name']
    img = compress_image(request.FILES['image'])
    fname=get_new_filename()
    fullpath=r"D:\snap2bill\snap2bill\media\\"+fname
    fs=FileSystemStorage()
    image=fs.save(fullpath,img)
    # price = request.POST['price']
    # quantity = request.POST['quantity']
    description = request.POST['description']
    category = request.POST['category']
    # obj = product(product_name=product_name,image=fs.url(image),price=price,quantity=quantity,description=description,CATEGORY_id=category)
    obj = product(product_name=product_name,image="/media/"+fname,description=description,CATEGORY_id=category)
    obj.save()
    # messages.success(request, f"Category '{category_name}' added successfully!")
    return redirect('/view_product')


@login_required(login_url='/')
def edit_product(request,id):
    data = product.objects.get(id=id)
    categorydata = category.objects.all()
    return render(request, 'admin/edit_product.html',{'data': data,'categorydata':categorydata})

@login_required(login_url='/')
def edit_product_post(request,id):
    product_name = request.POST['product_name']

    # price = request.POST['price']
    # quantity = request.POST['quantity']
    description = request.POST['description']
    category = request.POST['category']
    if 'image' in request.FILES:
        img = compress_image(request.FILES['image'])
        fs = FileSystemStorage()
        image = fs.save(img.name, img)
        product.objects.filter(id=id).update( image=fs.url(image))

    # product.objects.filter(id=id).update(product_name=product_name, price=price, quantity=quantity,description=description, CATEGORY_id=category)
    product.objects.filter(id=id).update(product_name=product_name,
                                         # quantity=quantity,
                                         description=description, CATEGORY_id=category)

    return redirect('/view_product')


@login_required(login_url='/')
def delete_product(request, id):
    obj = product.objects.get(id=id)

    obj.delete()
    # messages.error(request, f"Category '{name}' deleted.")
    return redirect('/view_product')



def distributor_view_product(request):
    # uid = request.POST['uid']
    # if not uid:
    #     return JsonResponse({'status': 'error', 'message': 'No distributor id'}, status=400)
    data = product.objects.all().order_by('-id')
    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'product_name': i.product_name,
            # 'price': i.price,
            'image': i.image,
            'description': i.description,
            # 'quantity': i.quantity,
            'CATEGORY': i.CATEGORY.id,
            'CATEGORY_NAME': getattr(i.CATEGORY, 'category_name', ''),
        })
    return JsonResponse({'status': 'ok', 'data': ar})


def view_other_products(request):
    uid = request.POST.get('uid')
    dist = distributor.objects.get(id=uid)

    data = stock.objects.exclude(DISTRIBUTOR=dist).order_by('-id')
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
    uid = request.POST.get('uid')  # .get() use karein taaki crash na ho

    # 1. Distributor Object layein (Wishlist check karne ke liye)
    try:
        dist_obj = distributor.objects.get(id=uid)
    except distributor.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Distributor not found'})

    # 2. Saare products layein
    data = stock.objects.filter(DISTRIBUTOR_id=uid).order_by('-id')

    ar = []
    for i in data:
        # 🚀 MAGIC STEP: Database mein column nahi hai, hum bas check kar rahe hain
        # "Kya ye wala Stock Item (i) is Distributor (dist_obj) ki wishlist mein hai?"

        is_in_wishlist = wishlist.objects.filter(
            STOCK=i,
            DISTRIBUTOR=dist_obj,
            USER__isnull=True
        ).exists()  # .exists() sirf True ya False deta hai

        ar.append({
            'id': i.id,
            'product_name': i.PRODUCT.product_name,
            'price': i.price,
            'image': i.PRODUCT.image,
            'description': i.PRODUCT.description,
            'quantity': i.quantity,
            'CATEGORY': i.PRODUCT.CATEGORY.id,
            'CATEGORY_NAME': getattr(i.PRODUCT.CATEGORY, 'category_name', ''),
            'unit_id': str(i.UNIT_id) if i.UNIT_id else "",
            'unit_name': i.UNIT.unit_name if i.UNIT else "pcs",
            'is_liked': is_in_wishlist,
        })

    return JsonResponse({'status': 'ok', 'data': ar})



def add_stock(request):
    quantity = request.POST['quantity']
    uid= request.POST['uid']
    pid = request.POST['pid']
    price = request.POST['price']
    unit_id = request.POST['unit_id']
    if stock.objects.filter(DISTRIBUTOR_id = uid,PRODUCT_id = pid).exists():
        return JsonResponse({"status":"not"})
    obj = stock()
    obj.quantity = quantity
    obj.price = price
    obj.DISTRIBUTOR_id = uid
    obj.PRODUCT_id = pid
    obj.UNIT_id =unit_id
    obj.save()

    return JsonResponse({'status':'ok'})

def edit_stock(request):
    if request.method == "POST":
        pid = request.POST.get('pid')
        quantity = request.POST.get('quantity')
        price = request.POST.get('price')
        unit_id = request.POST.get('unit_id')

        try:
            stock.objects.filter(id=pid).update(
                price=price,
                quantity=quantity,
                UNIT_id=unit_id
            )
            return JsonResponse({'status': 'ok'})
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)})

    return JsonResponse({'status': 'error', 'message': 'Invalid request method'})


def delete_distributor_product(request,id):
    stock.objects.filter(id=id).delete()
    return JsonResponse({'status':'ok'})


def customer_view_products(request):
    cid = request.POST.get('cid')
    user = customer.objects.get(id=cid) if cid else None

    data = stock.objects.all().order_by('-id')
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
    profile_image = compress_image(request.FILES['file'])
    fs = FileSystemStorage()
    path = fs.save(profile_image.name, profile_image)


    address = request.POST['address']
    pincode = request.POST['pincode']
    place = request.POST['place']
    post = request.POST['post']


    loc_obj = location.objects.create(
        address=address, place=place, pincode=pincode, post=post
    )


    name = request.POST['name']
    email = request.POST['email']
    phone = request.POST['phone']
    password = request.POST['password']
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
    ob.bio = bio
    ob.LOCATION = loc_obj
    ob.LOGIN = obj
    ob.save()

    return JsonResponse({'status': 'ok'})


def customer_view_profile(request):
    cid = request.POST['cid']
    data = customer.objects.select_related('LOCATION').filter(id=cid)

    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'name': i.name,
            'email': i.email,
            'phone': i.phone,
            'profile_image': i.profile_image,
            'bio': i.bio,
            'address': i.LOCATION.address if i.LOCATION else "",
            'place': i.LOCATION.place if i.LOCATION else "",
            'pincode': i.LOCATION.pincode if i.LOCATION else "",
            'post': i.LOCATION.post if i.LOCATION else ""
        })
    return JsonResponse({'status': 'ok', 'data': ar})



def edit_customer_profile(request):
    cid = request.POST['cid']
    cust_obj = customer.objects.get(id=cid)

    if 'file' in request.FILES:
        profile_image = compress_image(request.FILES['file'])
        fs = FileSystemStorage()
        path = fs.save(profile_image.name, profile_image)
        cust_obj.profile_image = fs.url(path)

    cust_obj.name = request.POST['name']
    cust_obj.phone = request.POST['phone']
    cust_obj.bio = request.POST['bio']
    cust_obj.save()

    if cust_obj.LOCATION:
        loc = cust_obj.LOCATION
        loc.address = request.POST['address']
        loc.pincode = request.POST['pincode']
        loc.place = request.POST['place']
        loc.post = request.POST['post']
        loc.save()

    return JsonResponse({'status': 'ok'})


def customer_view_distributor(request):
    try:
        cid = request.POST.get('cid')

        links = DistributorCustomerLink.objects.filter(CUSTOMER_id=cid).select_related('DISTRIBUTOR__LOCATION')

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
                'address': i.LOCATION.address if i.LOCATION else "",
                'place': i.LOCATION.place if i.LOCATION else "",
                'pincode': i.LOCATION.pincode if i.LOCATION else "",
                'post': i.LOCATION.post if i.LOCATION else "",

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
        i = stock.objects.get(id=pid)
        data = {
            'id': i.id,
            'product_name': i.PRODUCT.product_name,
            'price': i.price,
            'image': i.PRODUCT.image,
            'description': i.PRODUCT.description,
            'stock_quantity': i.quantity,
            'category': i.PRODUCT.CATEGORY.category_name,
            'distributor': i.DISTRIBUTOR.name,
            'unit_name': i.UNIT.unit_name if i.UNIT else ""
        }
        return JsonResponse({'status': 'ok', 'data': data})
    except stock.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Product not found'})


@csrf_exempt
def addorder(request):
    cid = request.POST.get('cid')
    product_stock_id = request.POST.get('pid')
    quantity = int(request.POST.get('quantity', 1))

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



# def viewCart(request):
#     # pid = request.POST['pid']
#     print(request.POST)
#     total = 0
#     data = cart.objects.filter(USER=request.POST['cid']).order_by('-id')
#     ar = []
#     for i in data:
#         total += float(i.STOCK.price) * float(i.quantity)
#         ar.append({
#             'id': i.id,
#             'product_name': i.STOCK.PRODUCT.product_name,
#             'price': i.STOCK.price,
#             'quantity': i.quantity,
#             'image':i.STOCK.PRODUCT.image,
#             'distributor_name':i.STOCK.DISTRIBUTOR.name,
#             'unit_name':i.STOCK.UNIT.unit_name,
#             "total":float(i.STOCK.price) * float(i.quantity)
#
#
#         })
#     return JsonResponse({'status':'ok','data':ar,"total":total})



def viewCart(request):
    total = 0
    data = cart.objects.filter(USER=request.POST['cid']).order_by('-id')
    ar = []
    for i in data:
        total += float(i.STOCK.price) * float(i.quantity)
        ar.append({
            'id': i.id,
            'product_name': i.STOCK.PRODUCT.product_name,
            'price': i.STOCK.price,
            'quantity': i.quantity,
            'image':i.STOCK.PRODUCT.image,
            'distributor_name':i.STOCK.DISTRIBUTOR.name,
            'unit_name':i.STOCK.UNIT.unit_name,
            "total":float(i.STOCK.price) * float(i.quantity),
            'stock_quantity': i.STOCK.quantity
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









@csrf_exempt  # Agar CSRF token issue aa raha ho
def toggle_wishlist(request):
    if request.method != 'POST':
        return JsonResponse({'status': 'error', 'msg': 'Only POST allowed'})

    pid = request.POST.get('pid') # Stock ID
    cid = request.POST.get('cid') # Customer ID
    uid = request.POST.get('uid') # Distributor ID

    # 1. Validation
    if not pid:
        return JsonResponse({'status': 'error', 'msg': 'Product ID (pid) missing'})

    # 2. Safe Stock Fetching
    try:
        stock_obj = stock.objects.get(id=pid)
    except stock.DoesNotExist:
        return JsonResponse({'status': 'error', 'msg': 'Product not found in stock'})

    try:
        # ================= CUSTOMER LOGIC =================
        if cid and cid not in ['null', 'None', '']:
            try:
                user = customer.objects.get(id=cid)
            except customer.DoesNotExist:
                return JsonResponse({'status': 'error', 'msg': 'Customer not found'})

            # Check if already exists
            wish_item = wishlist.objects.filter(
                STOCK=stock_obj,
                USER=user,
                DISTRIBUTOR__isnull=True
            ).first()

            if wish_item:
                wish_item.delete()
                return JsonResponse({'status': 'ok', 'action': 'removed'})
            else:
                wishlist.objects.create(
                    STOCK=stock_obj,
                    USER=user,
                    DISTRIBUTOR=None,
                    date=str(datetime.now()) # Better to use timezone.now() if model allows
                )
                return JsonResponse({'status': 'ok', 'action': 'added'})

        # ================= DISTRIBUTOR LOGIC =================
        elif uid and uid not in ['null', 'None', '']:
            try:
                dist = distributor.objects.get(id=uid)
            except distributor.DoesNotExist:
                return JsonResponse({'status': 'error', 'msg': 'Distributor not found'})

            wish_item = wishlist.objects.filter(
                STOCK=stock_obj,
                DISTRIBUTOR=dist,
                USER__isnull=True
            ).first()

            if wish_item:
                wish_item.delete()
                return JsonResponse({'status': 'ok', 'action': 'removed'})
            else:
                wishlist.objects.create(
                    STOCK=stock_obj,
                    DISTRIBUTOR=dist,
                    USER=None,
                    date=str(datetime.now())
                )
                return JsonResponse({'status': 'ok', 'action': 'added'})

        else:
            return JsonResponse({'status': 'error', 'msg': 'User ID (cid/uid) missing'})

    except Exception as e:
        print("Wishlist Error:", str(e))
        return JsonResponse({'status': 'error', 'msg': str(e)})


@csrf_exempt
def view_wishlist(request):
    cid = request.POST.get('cid')
    uid = request.POST.get('uid')

    if cid in ['null', 'None', '']: cid = None
    if uid in ['null', 'None', '']: uid = None

    queryset = wishlist.objects.select_related(
        'STOCK',
        'STOCK__PRODUCT',
        'STOCK__PRODUCT__CATEGORY',
        'STOCK__DISTRIBUTOR'
    ).order_by('-id')

    if cid:
        data = queryset.filter(USER__id=cid, DISTRIBUTOR__isnull=True)
    elif uid:
        data = queryset.filter(DISTRIBUTOR__id=uid, USER__isnull=True)
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


@csrf_exempt
def remove_from_wishlist(request):
    wid = request.POST.get('wid')
    cid = request.POST.get('cid')
    uid = request.POST.get('uid')

    if cid in ['null', 'None', '']: cid = None
    if uid in ['null', 'None', '']: uid = None

    if not wid:
        return JsonResponse({'status': 'error', 'msg': 'wid missing'})

    if cid:
        wishlist.objects.filter(id=wid, USER_id=cid, DISTRIBUTOR__isnull=True).delete()
    elif uid:
        wishlist.objects.filter(id=wid, DISTRIBUTOR_id=uid, USER__isnull=True).delete()

    return JsonResponse({'status': 'ok'})






def addFinalOrder(request):
    try:
        cid = request.POST['cid']
        cart_items = cart.objects.filter(USER_id=cid)

        if not cart_items.exists():
            return JsonResponse({'status': 'error', 'message': 'Cart is empty'})

        distributor_list = []
        for item in cart_items:
            dist_id = str(item.STOCK.DISTRIBUTOR_id)
            if dist_id not in distributor_list:
                distributor_list.append(dist_id)

        for d_id in distributor_list:
            DistributorCustomerLink.objects.get_or_create(
                DISTRIBUTOR_id=d_id,
                CUSTOMER_id=cid
            )

            new_order = order()
            new_order.USER_id = cid
            new_order.DISTRIBUTOR_id = d_id
            new_order.payment_status = 'pending'
            new_order.payment_date = "pending"
            new_order.date = datetime.now().date()
            new_order.amount = 0
            new_order.save()

            specific_dist_items = cart.objects.filter(USER_id=cid, STOCK__DISTRIBUTOR_id=d_id)

            order_total = 0
            for c_item in specific_dist_items:
                item_price = float(c_item.STOCK.price)
                item_qty = int(c_item.quantity)
                order_total += (item_price * item_qty)

                sub_obj = order_sub()
                sub_obj.ORDER_id = new_order.id
                sub_obj.STOCK_id = c_item.STOCK.id
                sub_obj.quantity = item_qty
                sub_obj.price = item_price
                sub_obj.save()

                # 🔥 NEW LOGIC: Stock Minus Karo
                stk = c_item.STOCK
                stk.quantity = int(stk.quantity) - item_qty
                stk.save()

                c_item.delete()

            new_order.amount = order_total
            new_order.save()

        return JsonResponse({'status': 'ok'})

    except Exception as e:
        print(f"Error in addFinalOrder: {e}")
        return JsonResponse({'status': 'error', 'message': str(e)})







def view_orders(request):
    cid = request.POST.get('cid')  # Customer ID
    did = request.POST.get('did')  # NEW: Distributor ID filter

    filters = {
        'USER_id': cid,
        'order_type__in': ["online", "offline"]  # 🚀 Sirf finalized orders/bills dikhao
    }
    if did and did not in ["", "null", "None"]:
        filters['DISTRIBUTOR_id'] = did

    data = order.objects.filter(**filters,).select_related('DISTRIBUTOR').order_by('-id')

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
            'order_type':i.order_type
        })
    return JsonResponse({'status': 'ok', 'data': ar})


def view_orders_items(request):
    order_id = request.POST.get('oid')
    items_data = order_sub.objects.filter(ORDER=order_id).order_by('-id')

    ar = []
    for i in items_data:
        ar.append({
            'id': i.id,
            'quantity': i.quantity,
            'sid': i.STOCK.id,
            'price': i.STOCK.price,
            'Discountedprice': i.price,
            'product_name': i.STOCK.PRODUCT.product_name,
            'image': i.STOCK.PRODUCT.image,
            'description': i.STOCK.PRODUCT.description,
            'unit_name': i.STOCK.UNIT.unit_name,
            'stock_quantity': i.STOCK.quantity
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
    if request.method == 'POST':
        item_id = request.POST.get('id')
        quantity = request.POST.get('quantity')
        price_override = request.POST.get('amount')
        unit_id = request.POST.get('unit_id')
        role = request.POST.get('role')

        try:
            obj = order_sub.objects.get(id=item_id)
            parent_order = obj.ORDER
            if parent_order.order_type == 'offline':
                return JsonResponse({
                    'status': 'error',
                    'message': 'This is an instant bill. Items can only be removed by the distributor.'
                })

            if parent_order.payment_status != 'pending':
                return JsonResponse({'status': 'error', 'message': 'Bill already processed'})

            # 🔥 NEW LOGIC: Difference nikaal kar Stock Update karo
            old_qty = int(obj.quantity)
            new_qty = int(quantity)
            qty_diff = new_qty - old_qty  # Puran 5 tha, Naya 8 kiya. Diff = 3. Stock se 3 katega.

            stk = obj.STOCK
            stk.quantity = int(stk.quantity) - qty_diff
            stk.save()

            if role == "customer":
                obj.quantity = quantity
                obj.save()

            elif role == "distributor":
                obj.quantity = quantity
                if price_override:
                    obj.price = price_override
                if unit_id:
                    stock_item = obj.STOCK
                    stock_item.UNIT_id = unit_id
                    stock_item.save()
                obj.save()

            all_items = order_sub.objects.filter(ORDER=parent_order)
            new_total = 0
            for item in all_items:
                current_price = item.price if item.price else item.STOCK.price
                new_total += int(item.quantity) * float(current_price)

            parent_order.amount = new_total
            parent_order.save()

            return JsonResponse({'status': 'ok'})

        except order_sub.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Item not found'})
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)})

    return JsonResponse({'status': 'error', 'message': 'Invalid request'})





def delete_order_item(request):
    try:
        id = request.POST['id']
        item = order_sub.objects.get(id=id)
        parent_order = item.ORDER
        orderid = parent_order.id

        if parent_order.order_type == 'offline':
            return JsonResponse({
                'status': 'error',
                'message': 'This is an instant bill. Items can only be removed by the distributor.'
            })

        # 🔥 NEW LOGIC: Item delete hone se pehle stock wapas add karo
        stk = item.STOCK
        stk.quantity = int(stk.quantity) + int(item.quantity)
        stk.save()

        item.delete()

        all_ordered_items = order_sub.objects.filter(ORDER=orderid)
        total = 0
        for i in all_ordered_items:
            total += int(i.quantity) * int(i.STOCK.price)

        if all_ordered_items.exists():
            order.objects.filter(id=orderid).update(amount=str(total))
        else:
            order.objects.filter(id=orderid).delete()

        return JsonResponse({'status': 'ok'})

    except order_sub.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Item not found'})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})

def delete_order(request):
    try:
            id = request.POST.get('id')
            order_obj = order.objects.get(id=id)

            if order_obj.order_type == 'offline':
                return JsonResponse({
                    'status': 'error',
                    'message': 'Instant bills cannot be deleted. Please contact the distributor.'
                })

            # 🔥 NEW LOGIC: Order delete hone se pehle uske saare items ka stock wapas karo
            order_items = order_sub.objects.filter(ORDER=order_obj)
            for item in order_items:
                stk = item.STOCK
                stk.quantity = int(stk.quantity) + int(item.quantity)
                stk.save()

            order_obj.delete()
            return JsonResponse({"status": "ok"})

    except order.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Order not found'})
    except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)})






def view_distributor_orders(request):
    uid = request.POST.get('uid')
    cid = request.POST.get('cid')
    data = order.objects.filter(DISTRIBUTOR_id=uid,USER_id=cid,order_type__in=["online","offline"]).select_related('USER').order_by('-id')
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
            'order_type':i.order_type
        })
    return JsonResponse({'status': 'ok', 'data': ar})

def view_distributor_allorders(request):
    uid = request.POST.get('uid')
    data = order.objects.filter(DISTRIBUTOR_id=uid,order_type__in=["online","offline"]).select_related('USER').order_by('-id')
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
            'order_type': i.order_type

        })
    return JsonResponse({'status': 'ok', 'data': ar})


@csrf_exempt
def view_distributor_ordersitems(request):
    try:
        oid = request.POST.get("id")
        cid = request.POST.get("cid")
        uid = request.POST.get("uid")
        print(f"Fetching items for: OID={oid}, CID={cid}, UID={uid}")
        target_order = None
        if oid and oid not in ["0", "", "null"]:
            try:
                target_order = order.objects.get(id=oid)
            except order.DoesNotExist:
                pass
        if not target_order and cid and uid:
            target_order = order.objects.filter(
                USER_id=cid,
                DISTRIBUTOR_id=uid,
                order_type="offline_pending"
            ).first()
        if not target_order:
            return JsonResponse({'status': 'ok', 'data': [], 'oid': "0"})
        data = order_sub.objects.filter(ORDER=target_order).order_by('-id')
        ar = []
        for i in data:
            price_to_show = i.price if i.price else i.STOCK.price
            ar.append({
                'id': i.id,
                'quantity': i.quantity,
                'image': i.STOCK.PRODUCT.image,
                'amount': price_to_show,
                'product_name': i.STOCK.PRODUCT.product_name,
                'username': i.ORDER.USER.name,
                'unit_id': str(i.STOCK.UNIT.id) if i.STOCK.UNIT else "",
                'unit_name': i.STOCK.UNIT.unit_name if i.STOCK.UNIT else "pcs",
                'stock_quantity': i.STOCK.quantity
            })
        return JsonResponse({'status': 'ok', 'data': ar, 'oid': str(target_order.id)})
    except Exception as e:
        print("Error fetching items:", e)
        return JsonResponse({'status': 'error', 'message': str(e)})



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




def scanItem(request):
    if request.method != "POST":
        return JsonResponse({'status': 'error', 'message': 'Invalid request'})

    uid = request.POST.get('uid')
    if not uid:
        return JsonResponse({'status': 'error', 'message': 'uid missing'})

    # 1. Distributor Stock Fetch
    allproduct = stock.objects.filter(DISTRIBUTOR_id=uid)
    if not allproduct.exists():
        return JsonResponse({'status': 'error', 'message': 'No stock found'})

    if 'image' not in request.FILES:
        return JsonResponse({'status': 'error', 'message': 'Image missing'})

    # 2. Image Handling
    image_file = request.FILES['image']
    fs = FileSystemStorage()
    saved_path = fs.save(image_file.name, image_file)
    image_path = fs.path(saved_path)

    img = cv2.imread(image_path)

    height, width = img.shape[:2]
    new_width = 640
    new_height = int((new_width / width) * height)
    img = cv2.resize(img, (new_width, new_height))

    # 2. Simple Contrast: Heavy Denoising hata di
    img = cv2.convertScaleAbs(img, alpha=1.1, beta=5)

    # Bytes conversion
    _, buffer = cv2.imencode(".jpg", img, [int(cv2.IMWRITE_JPEG_QUALITY), 85])
    image_bytes = io.BytesIO(buffer).getvalue()

    product_names = [item.PRODUCT.product_name for item in allproduct]
    product_list_text = ", ".join(product_names)
    api_key = os.getenv("GEMINI_API_KEY")
    genai.configure(api_key=api_key)
    model = genai.GenerativeModel("models/gemini-2.5-flash-lite")

    prompt = f"""Identify from: {product_list_text}. 
    Format: PRODUCT_NAME | QUANTITY. 
    If not found: NONE | 0."""

    try:
        response = model.generate_content([
            prompt,
            {"mime_type": "image/jpeg", "data": image_bytes}
        ])

        result_text = response.text.strip()

        # Quick Parsing
        parts = result_text.split('|')
        detected_name = parts[0].strip()
        detected_qty = parts[1].strip() if len(parts) > 1 else "1"

        print(f"📦 {detected_name} | 🔢 Qty: {detected_qty}")

        # 5. Database Match
        matched_stock = None
        for item in allproduct:
            if detected_name.lower() in item.PRODUCT.product_name.lower():
                matched_stock = item
                break

        # Cleanup
        if os.path.exists(image_path):
            os.remove(image_path)

        if matched_stock:
            return JsonResponse({
                'status': 'ok',
                'sid': matched_stock.id,
                'product_name': matched_stock.PRODUCT.product_name,
                'detected_qty': detected_qty
            })

        return JsonResponse({'status': 'not_found', 'detected': detected_name})

    except Exception as e:
        if os.path.exists(image_path): os.remove(image_path)
        print(f"Error: {e}")
        return JsonResponse({'status': 'error', 'message': str(e)})



#
# def scanItem(request):
#     if request.method != "POST":
#         return JsonResponse({
#             'status': 'error',
#             'message': 'Invalid request method'
#         })
#
#     # ============================
#     # 1. Get Distributor ID
#     # ============================
#     uid = request.POST.get('uid')
#     print(uid,"kl")
#     if not uid:
#         return JsonResponse({
#             'status': 'error',
#             'message': 'uid missing'
#         })
#
#     # ============================
#     # 2. Fetch Distributor Stock
#     # ============================
#     allproduct = stock.objects.filter(DISTRIBUTOR_id=uid)
#
#     if not allproduct.exists():
#         return JsonResponse({
#             'status': 'error',
#             'message': 'No stock found for distributor'
#         })
#
#     # ============================
#     # 3. Image Validation & Save
#     # ============================
#     if 'image' not in request.FILES:
#         return JsonResponse({
#             'status': 'error',
#             'message': 'Image missing'
#         })
#
#     image_file = request.FILES['image']
#     fs = FileSystemStorage()
#     saved_path = fs.save(image_file.name, image_file)
#     image_path = fs.path(saved_path)
#     print(image_path,"oky")
#
#     # ============================
#     # 4. Convert Image → Bytes
#     # ============================
#     image = Image.open(image_path).convert("RGB")
#     image_bytes_io = io.BytesIO()
#     image.save(image_bytes_io, format="JPEG")
#     image_bytes = image_bytes_io.getvalue()
#
#     # ============================
#     # 5. Prepare Product List
#     # ============================
#     product_names = []
#     for item in allproduct:
#         product_names.append(item.PRODUCT.product_name)
#
#     product_list_text = ", ".join(product_names)
#
#     # ============================
#     # 6. Gemini Configuration
#     # ============================
#     genai.configure(api_key="AIzaSyAnlXqmMIpse1oKCNfDkTIwGPOSEruCVHI")  # 🔐 move to settings in production
#
#     model = genai.GenerativeModel("models/gemini-2.5-flash-lite")
#
#     prompt = f"""
# You are given:
# 1. An image of a product
# 2. A list of product names
#
# TASK:
# - Identify the product shown in the image
# - Compare it strictly with the product list
# - Return ONLY the best matching product name from the list
# - If no product clearly matches, return ONLY: NONE
#
# RULES:
# - Output must be EXACTLY one product name from the list
# - No extra words, no punctuation, no explanation
#
# PRODUCT LIST:
# {product_list_text}
# """
#
#     # ============================
#     # 7. Gemini Image Comparison
#     # ============================
#     response = model.generate_content(
#         [
#             prompt,
#             {"mime_type": "image/jpeg", "data": image_bytes}
#         ],
#         generation_config={
#             "temperature": 0.1,
#             "max_output_tokens": 30
#         }
#     )
#
#     detected_product = response.text.strip()
#     print("Gemini detected:", detected_product)
#
#     # ============================
#     # 8. Match with Stock (Exact)
#     # ============================
#     matched_stock = None
#     for item in allproduct:
#         db_name = item.PRODUCT.product_name.strip().lower()
#         ai_name = detected_product.strip().lower()
#         if ai_name == db_name or ai_name in db_name or db_name in ai_name:
#             matched_stock = item
#             break
#
#     import os
#
#     file_path = image_path
#
#     if os.path.exists(file_path):
#         os.remove(file_path)
#         print(f"The file {file_path} has been removed.")
#     else:
#         print(f"The file {file_path} does not exist.")
#     if matched_stock:
#         print(f"Match found: {matched_stock}")
#         return JsonResponse({
#             'status': 'ok',
#             'sid': matched_stock.id,
#             'product_name': matched_stock.PRODUCT.product_name,
#         })
#     else:
#         print("Match failed: Stock not found in database for detected name.")
#         return JsonResponse({'status': 'not_found', 'detected': detected_product})


def viewAllCustomers(request):
    uid = request.POST['uid']
    try:
        data = customer.objects.select_related('LOCATION').all()
        ar = []
        for i in data:
            data2 = order.objects.filter(order_type="offline_pending", USER_id=i.id, DISTRIBUTOR_id=uid)
            current_oid = data2[0].id if data2.exists() else 0
            ar.append({
                'id': i.id,
                'name': i.name,
                'email': i.email,
                'phone': i.phone,
                'profile_image': i.profile_image,
                'address': i.LOCATION.address if i.LOCATION else "",
                'place': i.LOCATION.place if i.LOCATION else "",
                'pincode': i.LOCATION.pincode if i.LOCATION else "",
                'post': i.LOCATION.post if i.LOCATION else "",
                'bio': i.bio,
                'oid': current_oid
            })

        return JsonResponse({'status': 'ok', 'data': ar})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})



# @csrf_exempt
# def addtobill(request):
#     try:
#             # Get all possible identifiers
#             uid = request.POST.get('uid')
#             cid = request.POST.get('cid')
#             sid = request.POST.get('sid')
#             oid = request.POST.get('oid')
#
#             quantity = request.POST.get('quantity', 1)
#             price = request.POST.get('price')
#
#             print(f"Adding to bill: UID={uid}, CID={cid}, SID={sid}, OID={oid}")
#
#             # 1. Basic Validation
#             if not uid or not sid:
#                 return JsonResponse({'status': 'error', 'message': 'Missing UID or SID'})
#
#             if cid:
#                 DistributorCustomerLink.objects.get_or_create(
#                     DISTRIBUTOR_id=uid,
#                     CUSTOMER_id=cid
#                 )
#
#             qty_int = int(float(quantity))
#             target_order = None
#
#             if oid and oid not in ["", "null", "0"]:
#                 try:
#                     target_order = order.objects.get(id=oid)
#                 except order.DoesNotExist:
#                     pass
#
#             if not target_order and cid:
#                 target_order = order.objects.filter(
#                     USER_id=cid,
#                     DISTRIBUTOR_id=uid,
#                     order_type='offline_pending'
#                 ).first()
#
#             if not target_order:
#                 if not cid:
#                     return JsonResponse(
#                         {'status': 'error', 'message': 'Cannot find bill. Restart the app or re-select customer.'})
#
#                 # Create NEW Bill
#                 target_order = order.objects.create(
#                     payment_status="pending",
#                     payment_date="pending",
#                     date=datetime.now().date(),
#                     amount=0,
#                     DISTRIBUTOR_id=uid,
#                     USER_id=cid,
#                     order_type="offline_pending"
#                 )
#
#             existing_item = order_sub.objects.filter(ORDER=target_order, STOCK_id=sid).first()
#
#             if existing_item:
#                 existing_item.quantity = int(existing_item.quantity) + qty_int
#                 existing_item.save()
#             else:
#                 order_sub.objects.create(
#                     ORDER=target_order,
#                     STOCK_id=sid,
#                     quantity=qty_int,
#                     price=price
#                 )
#
#             return JsonResponse({'status': 'ok', 'oid': target_order.id})
#
#     except Exception as e:
#             print("Error in addtobill:", str(e))
#             return JsonResponse({'status': 'error', 'message': str(e)})


@csrf_exempt
def addtobill(request):
    try:
        uid = request.POST.get('uid')
        cid = request.POST.get('cid')
        sid = request.POST.get('sid')
        oid = request.POST.get('oid')
        quantity = request.POST.get('quantity', 1)
        price = request.POST.get('price')

        if not uid or not sid:
            return JsonResponse({'status': 'error', 'message': 'Missing UID or SID'})

        if cid:
            DistributorCustomerLink.objects.get_or_create(
                DISTRIBUTOR_id=uid,
                CUSTOMER_id=cid
            )

        qty_int = int(float(quantity))

        # 🔥 NEW LOGIC: Pehle check karo ki stock hai ya nahi, aur fir minus karo
        stk = stock.objects.get(id=sid)
        if int(stk.quantity) < qty_int:
            return JsonResponse({'status': 'error', 'message': 'Not enough stock!'})

        stk.quantity = int(stk.quantity) - qty_int
        stk.save()
        # 🔥 =======================================

        target_order = None
        if oid and oid not in ["", "null", "0"]:
            try:
                target_order = order.objects.get(id=oid)
            except order.DoesNotExist:
                pass

        if not target_order and cid:
            target_order = order.objects.filter(
                USER_id=cid, DISTRIBUTOR_id=uid, order_type='offline_pending'
            ).first()

        if not target_order:
            if not cid:
                return JsonResponse({'status': 'error', 'message': 'Cannot find bill. Restart the app.'})

            target_order = order.objects.create(
                payment_status="pending", payment_date="pending",
                date=datetime.now().date(), amount=0,
                DISTRIBUTOR_id=uid, USER_id=cid, order_type="offline_pending"
            )

        existing_item = order_sub.objects.filter(ORDER=target_order, STOCK_id=sid).first()

        if existing_item:
            existing_item.quantity = int(existing_item.quantity) + qty_int
            existing_item.save()
        else:
            order_sub.objects.create(
                ORDER=target_order, STOCK_id=sid,
                quantity=qty_int, price=price
            )

        return JsonResponse({'status': 'ok', 'oid': target_order.id})

    except Exception as e:
        print("Error in addtobill:", str(e))
        return JsonResponse({'status': 'error', 'message': str(e)})


def addFinalBill(request):
   id = request.POST['id']

   total = request.POST['total']
   print(id,"  total  ",total)
   today = datetime.now().date()
   order.objects.filter(id=id).update(amount = total,order_type = "offline",date=today)


   return JsonResponse({'status': 'ok'})








def universal_search(request):
    query = request.GET.get('q', '').strip()
    page_number = request.GET.get('page', 1)
    limit = 20
    results = []

    if not query:
        items = stock.objects.all()
        for s in items:
            results.append({
                'type': 'product',
                'id': s.id,
                'name': s.PRODUCT.product_name,
                'image': s.PRODUCT.image,
                'category': s.PRODUCT.CATEGORY.category_name,
                'price': s.price,
                'description': s.PRODUCT.description,
                'distributor_id': s.DISTRIBUTOR.id,
                'distributor_name': s.DISTRIBUTOR.name,
                'distributor_phone': s.DISTRIBUTOR.phone,
                'distributor_image': s.DISTRIBUTOR.profile_image,
                'is_liked': False
            })
    else:
        # A. Products Search
        stock_qs = stock.objects.filter(
            Q(PRODUCT__product_name__icontains=query) |
            Q(PRODUCT__CATEGORY__category_name__icontains=query)
        ).distinct().order_by('-id')

        for s in stock_qs:
            results.append({
                'type': 'product', 'id': s.id, 'name': s.PRODUCT.product_name,
                'image': s.PRODUCT.image,
                'category': s.PRODUCT.CATEGORY.category_name, 'price': s.price,
                'description': s.PRODUCT.description, 'distributor_id': s.DISTRIBUTOR.id,
                'distributor_name': s.DISTRIBUTOR.name, 'distributor_phone': s.DISTRIBUTOR.phone,
                'distributor_image': s.DISTRIBUTOR.profile_image
            })

        customers = customer.objects.filter(
            Q(name__icontains=query) |
            Q(LOCATION__place__icontains=query)  # Foreign Key Search
        ).select_related('LOCATION')

        for c in customers:
            results.append({
                'type': 'customer',
                'id': c.id,
                'name': c.name,
                'place': c.LOCATION.place,
                'phone': c.phone,
                'image': c.profile_image,
                'email': c.email,
                'bio': c.bio,
                'address': c.LOCATION.address,
                'pincode': c.LOCATION.pincode,
                'post': c.LOCATION.post
            })

        distributors = distributor.objects.filter(
            Q(name__icontains=query) |
            Q(LOCATION__place__icontains=query)
        ).select_related('LOCATION')

        for d in distributors:
            results.append({
                'type': 'distributor',
                'id': d.id,
                'name': d.name,
                'place': d.LOCATION.place,
                'phone': d.phone,
                'image': d.profile_image,
                'email': d.email,
                'bio': d.bio,
                'address': d.LOCATION.address,
                'pincode': d.LOCATION.pincode,
                'post': d.LOCATION.post
            })

    paginator = Paginator(results, limit)
    try:
        page_obj = paginator.page(page_number)
    except (PageNotAnInteger, EmptyPage):
        return JsonResponse({'status': 'ok', 'data': [], 'has_next': False})

    return JsonResponse({
        'status': 'ok',
        'data': list(page_obj),
        'has_next': page_obj.has_next()
    })


def distributor_add_product(request):
    try:
        uid = request.POST['uid']
        image = compress_image(request.FILES['file'])
        product_name = request.POST['product_name']
        price = request.POST['price']
        description = request.POST['description']
        quantity = request.POST['quantity']
        category_id = request.POST['category']
        unit_id = request.POST['unit_id']

        fs = FileSystemStorage()
        file_name = fs.save(image.name, image)
        image_url = fs.url(file_name)

        new_product = product()
        new_product.product_name = product_name
        new_product.image = image_url
        new_product.description = description
        new_product.CATEGORY_id = category_id
        new_product.save()

        obj = stock()
        obj.PRODUCT = new_product
        obj.DISTRIBUTOR_id = uid
        obj.price = price
        obj.quantity = quantity
        obj.UNIT_id = unit_id
        obj.save()

        return JsonResponse({'status': 'ok'})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})








def get_incremental_suggestions(request):
    try:
        current_sid = request.POST.get('sid')
        if not current_sid:
            return JsonResponse({'status': 'error', 'message': 'sid missing'})
        current_sid = int(current_sid)
        order_items = order_sub.objects.all().select_related('ORDER')
        user_session_transactions = defaultdict(list)
        for item in order_items:
            session_key = f"user_{item.ORDER.USER_id}_{item.ORDER.date}"
            user_session_transactions[session_key].append(item.STOCK_id)
        related_items_count = defaultdict(int)
        for session_id in user_session_transactions:
            product_list = user_session_transactions[session_id]
            if current_sid in product_list:
                for other_item in product_list:
                    if other_item != current_sid:
                        related_items_count[other_item] += 1
        sorted_related = sorted(related_items_count.items(), key=lambda x: x[1], reverse=True)[:5]
        ar = []
        for sid, score in sorted_related:
            try:
                item = stock.objects.get(id=sid)
                ar.append({
                    'id': item.id,
                    'product_name': item.PRODUCT.product_name,
                    'price': item.price,
                    'image': item.PRODUCT.image,
                    'unit': item.UNIT.unit_name if item.UNIT else "pcs",
                    'distributor_name': item.DISTRIBUTOR.name,
                    'confidence_score': score
                })
            except stock.DoesNotExist:
                continue

        return JsonResponse({'status': 'ok', 'data': ar})

    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})




def add_to_recent(request):
    try:
        cid = request.POST.get('cid')
        sid = request.POST.get('sid')

        obj, created = recently_viewed.objects.update_or_create(
            USER_id=cid, STOCK_id=sid,
            defaults={'viewed_date': timezone.now()}
        )
        all_recent = recently_viewed.objects.filter(USER_id=cid).order_by('-viewed_date')
        if all_recent.count() > 10:
            ids_to_keep = all_recent.values_list('pk', flat=True)[:10]
            recently_viewed.objects.filter(USER_id=cid).exclude(pk__in=ids_to_keep).delete()

        return JsonResponse({'status': 'ok'})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})


def get_recent_products(request):
    try:
        cid = request.POST.get('cid')
        data = recently_viewed.objects.filter(USER_id=cid).order_by('-viewed_date')[:10]

        ar = []
        for i in data:
            item = i.STOCK
            ar.append({
                'id': item.id,
                'product_name': item.PRODUCT.product_name,
                'price': item.price,
                'image': item.PRODUCT.image,
                'distributor': item.DISTRIBUTOR.name,
                'unit': item.UNIT.unit_name if item.UNIT else "pcs"
            })
        return JsonResponse({'status': 'ok', 'data': ar})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})


def get_counts(request):
    uid = request.POST.get('uid')
    cid = request.POST.get('cid')
    wishlist_count = 0
    cart_count = 0
    if uid:
        wishlist_count = wishlist.objects.filter(DISTRIBUTOR_id=uid, USER__isnull=True).count()
    elif cid:
        wishlist_count = wishlist.objects.filter(USER_id=cid, DISTRIBUTOR__isnull=True).count()
        cart_count = cart.objects.filter(USER_id=cid).count()

    return JsonResponse({
        'status': 'ok',
        'wishlist_count': wishlist_count,
        'cart_count': cart_count
    })


@csrf_exempt
def auth_google(request):
    if request.method != 'POST':
        return JsonResponse({'status': 'error', 'message': 'Invalid method'}, status=405)

    try:
        data = json.loads(request.body)
        email = data.get('email')
        name = data.get('name')
        photo = data.get('photoUrl')
        user_type = data.get('type')
        phone = data.get('phone', '')

        # Ye fields frontend se shayad empty aa rahe honge, koi dikkat nahi
        address = data.get('address', '')
        place = data.get('place', '')
        pincode = data.get('pincode', '')
        post = data.get('post', '')
        latitude = data.get('latitude', '')
        longitude = data.get('longitude', '')

        if not email:
            return JsonResponse({'status': 'error', 'message': 'Email is required'}, status=400)

        # 🔍 Check karte hain user pehle se hai ya nahi
        user_exists = User.objects.filter(username=email).exists()

        if user_exists:
            # =================================================
            # CASE 1: LOGIN (EXISTING USER)
            # Yahan hum Location create NAHI karenge.
            # =================================================
            user = User.objects.get(username=email)

            if user.groups.filter(name="distributor").exists():
                try:
                    dist = distributor.objects.get(LOGIN=user)
                    # Sirf photo update karenge agar pehle se nahi hai
                    if not dist.profile_image and photo:
                        dist.profile_image = photo
                        dist.save()
                    return JsonResponse({'status': 'distok', 'uid': str(dist.id)})
                except distributor.DoesNotExist:
                    return JsonResponse({'status': 'error', 'message': 'User exists but no profile found'})

            elif user.groups.filter(name="customer").exists():
                try:
                    cust = customer.objects.get(LOGIN=user)
                    if not cust.profile_image and photo:
                        cust.profile_image = photo
                        cust.save()
                    return JsonResponse({'status': 'custok', 'cid': str(cust.id)})
                except customer.DoesNotExist:
                    return JsonResponse({'status': 'error', 'message': 'User exists but no profile found'})
            else:
                return JsonResponse({'status': 'error', 'message': 'User type unknown'})

        else:
            # =================================================
            # CASE 2: REGISTRATION (NEW USER)
            # Sirf yahan Location banegi
            # =================================================

            # 🚀 CHANGE: Location object ab sirf naye user ke liye banega
            loc_obj = location.objects.create(
                address=address, place=place, pincode=pincode, post=post
            )

            random_password = User.objects.make_random_password()
            new_user = User.objects.create_user(username=email, email=email, password=random_password)
            new_user.first_name = name
            new_user.save()

            if user_type == 'distributor':
                group = Group.objects.get(name='distributor')
                new_user.groups.add(group)

                obj = distributor()
                obj.LOGIN = new_user
                obj.name = name
                obj.email = email
                obj.phone = phone
                obj.LOCATION = loc_obj  # Link Location
                obj.latitude = latitude
                obj.longitude = longitude
                obj.profile_image = photo
                obj.status = 'pending'
                obj.save()

                return JsonResponse({'status': 'distok', 'uid': str(obj.id)})

            elif user_type == 'customer':
                group = Group.objects.get(name='customer')
                new_user.groups.add(group)

                obj = customer()
                obj.LOGIN = new_user
                obj.name = name
                obj.email = email
                obj.phone = phone
                obj.LOCATION = loc_obj  # Link Location
                obj.profile_image = photo
                obj.save()

                return JsonResponse({'status': 'custok', 'cid': str(obj.id)})

            else:
                new_user.delete()
                # Location bhi delete kar do agar user type galat hai
                loc_obj.delete()
                return JsonResponse({'status': 'error', 'message': 'Invalid user type'})

    except Exception as e:
        print("Google Auth Error:", e)
        return JsonResponse({'status': 'error', 'message': str(e)}, status=500)