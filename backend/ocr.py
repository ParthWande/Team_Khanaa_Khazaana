import fitz  # PyMuPDF
import pytesseract
from PIL import Image
import re
import cv2
import urllib
import numpy as np
def extract_text_from_pdf(pdf_path):
    
    text = ""
    
    with fitz.open(pdf_path) as pdf_document:
        for page_num in range(pdf_document.page_count):
            page = pdf_document[page_num]
            text += page.get_text()
    
    return text

def extract_medicine_names_from_text(text):
    medicine_names = []

    # Use regex to find potential medicine names
    potential_medicine_matches = re.findall(r'\b[A-Za-z]+\b', text)

    # Filter out common non-medicine words
    medicine_matches = [name for name in potential_medicine_matches if len(name) > 3]

    medicine_names.extend(medicine_matches)

    return medicine_names

def extract_medicine_names(url):
    url_response = urllib.request.urlopen(url)
    img_array = np.array(bytearray(url_response.read()), dtype=np.uint8)
    img = cv2.imdecode(img_array, -1)
    text = pytesseract.image_to_string(img)
    # Extract medicine names from the extracted text
    medicine_names = extract_medicine_names_from_text(text)
    return medicine_names

# # Replace 'your_file.pdf' or 'your_image.jpg' with the path to your actual file
# file_path = 'your_file.pdf'
# result = extract_medicine_names(file_path)

# # Display the extracted medicine names
# print("Extracted Medicine Names:")
# print(result)