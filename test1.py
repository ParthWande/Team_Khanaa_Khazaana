# import csv

# file_path = 'chatbot\\combined_data.csv'

# # Read the CSV file
# with open(file_path, 'r', encoding='utf-8') as csv_file:
#     reader = csv.DictReader(csv_file)
#     medicine_names_with_tablet = [row['name'] for row in reader if ' gel ' in row['name'].lower()]

# # Print the filtered medicine names
# for name in medicine_names_with_tablet:
#     try:
#         print(name)
#     except UnicodeEncodeError:
#         print(name.encode('utf-8', 'replace').decode('utf-8'))
from flask import Flask, request, jsonify
import csv

app = Flask(__name__)

file_path = 'chatbot\\combined_data.csv'

def get_filtered_medicine_data(medicine_type):
    with open(file_path, 'r', encoding='utf-8') as csv_file:
        reader = csv.DictReader(csv_file)
        filtered_data = [
            {
                'name': row['name'],
                'composition': row['composition'],
                'uses': row['uses'][1:-1] if row['uses'] and len(row['uses']) > 2 else row['uses'],
            }
            for row in reader if f' {medicine_type.lower()} ' in f' {row["name"].lower()} '
        ][:10]  # Only return the first 10 items
    return filtered_data

@app.route('/medicine/<medicine_type>', methods=['GET'])
def get_medicine_data(medicine_type):
    medicine_data = get_filtered_medicine_data(medicine_type)
    return jsonify({'medicine_data': medicine_data})

if __name__ == '__main__':
    app.run(debug=True)


