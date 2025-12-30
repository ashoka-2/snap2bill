# from django.test import TestCase
#
# # Create your tests here.
# import google.generativeai as genai
#
# # Configure with your API key
# genai.configure(api_key="AIzaSyAduEHNgfrIKbihOtLOAUJf9NsoXsw7MW0")  # Replace with your actual key
#
# message = "http://192.168.29.6:8000/media/images.webp"
#
# for m in genai.list_models():
#     print(m.name, "→", m.supported_generation_methods)
#
# # Initialize the model (using the correct flash model)
# model = genai.GenerativeModel('models/gemini-2.5-flash-lite')  # ✅ Current fastest model
# # Generate response with chatbot personality
# response = model.generate_content(
#     f"""{message} identify the object""",
#     generation_config={
#         "temperature": 0.7,
#         "max_output_tokens": 500
#     }
# )
# print("\nGemini:", response.text, "\n")


import google.generativeai as genai
from PIL import Image
import io

# Configure with your API key
genai.configure(api_key="AIzaSyAduEHNgfrIKbihOtLOAUJf9NsoXsw7MW0")

# Initialize the model
model = genai.GenerativeModel('models/gemini-2.5-flash-lite')

# Load the image using Pillow
image_path = r"D:\snap2bill\snap2bill\media\images.webp"
image = Image.open(image_path)

# Convert the image to bytes
image_bytes = io.BytesIO()
image.save(image_bytes, format="JPEG")
image_bytes = image_bytes.getvalue()

# Generate response with object identification
response = model.generate_content(
    ["Identify the objects in this image:", {"mime_type": "image/jpeg", "data": image_bytes}],
    generation_config={
        "temperature": 0.7,
        "max_output_tokens": 500
    }
)

print(response.text)