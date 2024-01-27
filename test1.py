from flask import Flask, request, jsonify, send_file
import csv
import json
import qrcode
from io import BytesIO

app = Flask(__name__)

file_path = 'combined_data.csv'

with open('image.json', 'r') as json_file:
    image_data = json.load(json_file)

def generate_upi_link(amount, payee_name, upi_id, message="Payment"):
    upi_link = f"upi://pay?pa={upi_id}&pn={payee_name}&mc=&tid=&tr={message}&tn={message}&am={amount}&cu=INR"
    return upi_link

def get_image_url(query):
    # Check if image links are available in image_data
    links = image_data.get(query.lower())
    return links if links else image_data.get("eye drop")

def get_filtered_medicine_data(medicine_type):
    with open(file_path, 'r', encoding='utf-8') as csv_file:
        reader = csv.DictReader(csv_file)
        filtered_data = []
        image_urls = get_image_url(medicine_type.lower())
        i = 0
        for row in reader:
            if f' {medicine_type.lower()} ' in f' {row["name"].lower()} ':
                data = {
                    'name': row['name'],
                    'composition': row['composition'],
                    'uses': row['uses'][1:-1] if row['uses'] and len(row['uses']) > 2 else row['uses'],
                    'image_urls': image_urls[i]
                }
                i = (i + 1) % len(image_urls)  # Cycle through image URLs
                filtered_data.append(data)
                if len(filtered_data) >= 10:
                    break  # Limit to the first 10 items
        return filtered_data

@app.route('/medicine/<medicine_type>', methods=['GET'])
def get_medicine_data(medicine_type):
    medicine_data = get_filtered_medicine_data(medicine_type)
    return jsonify({'medicine_data': medicine_data})

@app.route('/order/<total_price>', methods=['GET'])
def generate_upi_url(total_price):
    try:
        total_price = float(total_price)
        payee_name = "Aniket"  # Replace with your business name
        upi_id = "9372846997@ybl"  # Replace with your UPI ID

        upi_link = generate_upi_link(total_price, payee_name, upi_id)
        return jsonify({'upi_url': upi_link})

    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/order/qr/<total_price>', methods=['GET'])
def generate_qr_code(total_price):
    try:
        total_price = float(total_price)
        payee_name = "Aniket"  # Replace with your business name
        upi_id = "9372846997@ybl"  # Replace with your UPI ID

        upi_link = generate_upi_link(total_price, payee_name, upi_id)

        # Generate QR code
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        qr.add_data(upi_link)
        qr.make(fit=True)

        # Create BytesIO object to store the QR code image
        qr_img_bytes = BytesIO()
        img = qr.make_image(fill_color="black", back_color="white")
        img.save(qr_img_bytes)
        qr_img_bytes.seek(0)

        # Send QR code image as a response
        return send_file(qr_img_bytes, mimetype='image/png', as_attachment=True, download_name='qrcode.png')

    except Exception as e:
        return jsonify({'error': str(e)}), 400
    
if __name__ == '__main__':
    app.run(port=5001, debug=True)





