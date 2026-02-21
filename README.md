# 🛒 SNAP2BILL: AI-Powered Visual Billing & E-Commerce Platform

![Flutter](https://img.shields.io/badge/Frontend-Flutter-blue?logo=flutter)
![Django](https://img.shields.io/badge/Backend-Django-darkgreen?logo=django)
![MySQL](https://img.shields.io/badge/Database-MySQL-orange?logo=mysql)
![Gemini AI](https://img.shields.io/badge/AI-Google_Gemini-blueviolet?logo=google)

## 📖 About The Project

**SNAP2BILL** is an innovative, dual-platform (Mobile + Web) application designed to bridge the gap between wholesale distributors and retail customers. It revolutionizes the traditional checkout process by replacing fragile barcode scanners with robust **AI-based Image Recognition**. 

Aimed at solving grassroots retail challenges, Snap2Bill generates **Visual Bills** containing actual product images. This effectively breaks down language and literacy barriers, empowering staff with limited education to verify items easily and eliminating billing errors. The platform perfectly balances an offline quick-billing POS tool with a modern online retail E-commerce feed.

## ✨ Key Features

### 🏪 For Distributors (Sellers)
* **AI Camera Billing:** Point the smartphone camera at a product, and the Gemini AI instantly recognizes it and adds it to the bill. No barcode required!
* **Visual PDF Bills:** Generates bills with product images, names, and total amounts, which can be exported as PDFs and shared directly via WhatsApp.
* **Smart Inventory Management:** Easily update stock, add custom products, and track offline POS sales.

### 🛍️ For Customers (Buyers)
* **Unified E-Commerce Feed:** Browse an Instagram-style global feed of products available from verified distributors.
* **Smart Recommendations:** AI-driven personalized suggestions like "Recently Viewed" and "Frequently Bought Together".
* **Seamless Checkout:** Add items to the cart, specify quantities, and place online orders effortlessly.

### 🛡️ Core System Features
* **Google Authentication:** Secure login with automatic GPS location fetching.
* **Image Optimization:** Server-side image compression (Pillow/HEIF) and mobile caching for lag-free performance.
* **Dark/Light Mode Support:** Adaptive and accessible user interface.

## 💻 Tech Stack

* **Mobile App (Client):** Flutter (Dart)
* **Backend Server (API):** Python, Django REST Framework
* **Database:** MySQL
* **AI Engine:** Google Generative AI (Gemini API)
* **Web Frontend (Admin):** HTML5, CSS3, JavaScript, Bootstrap

## ⚙️ System Architecture

The system follows a scalable Client-Server architecture. The Flutter mobile application communicates with the Django REST API, which securely interacts with the MySQL database and the external Google Gemini API for real-time image processing.



## 🚀 Installation & Setup

Follow these steps to set up the project locally on your machine based on the repository structure.

### Prerequisites
* Python 3.9+
* Flutter SDK (Version 3.10+)
* MySQL Server (XAMPP / MySQL Workbench)
* Google Gemini API Key

### Clone the Repository
```bash
git clone [https://github.com/ashoka-2/snap2bill.git](https://github.com/ashoka-2/snap2bill.git)
cd snap2bill
# Navigate to the Django backend directory
cd snap2bill

# Create and activate a virtual environment
python -m venv env
source env/bin/activate  # On Windows use: env\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure Database
# Open `settings.py` and update your MySQL credentials, then run:
python manage.py makemigrations
python manage.py migrate

# Create a superuser (Admin)
python manage.py createsuperuser

# Add your Gemini API Key (Set it in your environment variables or .env file)
# GEMINI_API_KEY=your_api_key_here

# Run the local server
python manage.py runserver


# Open a new terminal and navigate to the Flutter app directory from the repository root
cd flutter/snap2bill

# Install Flutter dependencies
flutter pub get

# Run the app on an emulator or connected physical device
flutter run
```
🔮 Future Enhancements
Khata Book Integration: Digital ledger for tracking customer credit and automated WhatsApp payment reminders.

AI-Powered Background Removal: Automatically removing cluttered backgrounds from product images captured in shops to create premium studio-like catalog listings.

On-Device AI: Integrating TensorFlow Lite for offline product recognition without internet dependency.

Dynamic UPI QR: Embedding auto-generated UPI QR codes on PDF bills for instant payments.

👥 Contributor
Ashoka - Lead Developer / System Designer

GitHub: @ashoka-2

📄 License
This project is created for academic and demonstration purposes.



