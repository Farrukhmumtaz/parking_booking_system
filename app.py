from flask import Flask, jsonify, request, session
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import pyqrcode
from PIL import Image
import numpy as np
import io

app = Flask(__name__)
CORS(app)

# Set a secret key for sessions
app.secret_key = 'kaka bhai'

# Dummy data for parking slots (100 slots with time and location)
parking_slots = [
    {
        "slot_id": f"Slot-{i+1}",
        "status": "Available" if i % 2 == 0 else "Occupied",
        "time": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "location": f"Level {i // 10 + 1}, Row {i % 10 + 1}"
    }
    for i in range(100)
]

# Dummy data for bookings (used to store current and previous bookings)
bookings = []

# Dummy user data (in-memory for now, replace with a database in production)
# Dummy user data (in-memory for now, replace with a database in production)
users = {
    "admin": {
        "username": "admin",
        "password": generate_password_hash("admin123")  # Default password
    }
}


# Route to handle login (POST request)
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    # Check if username exists and if the password matches
    user = users.get(username)
    if user and check_password_hash(user['password'], password):
        session['username'] = username
        return jsonify({"message": "Login successful"}), 200
    else:
        return jsonify({"message": "Invalid credentials"}), 400

# Route to handle account creation (POST request)
@app.route('/create_account', methods=['POST'])
def create_account():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    # Check if the username already exists
    if username in users:
        return jsonify({"message": "Username already exists"}), 400

    # Hash the password for secure storage
    hashed_password = generate_password_hash(password)

    # Store user data
    users[username] = {'username': username, 'password': hashed_password}
    
    return jsonify({"message": "Account created successfully"}), 201

# Route to get all parking slots
@app.route('/slots', methods=['GET'])
def get_parking_slots():
    return jsonify({"available_slots": parking_slots}), 200

# Route for Instant Booking (with photo upload for YOLO detection)
@app.route('/instant_booking', methods=['GET','POST'])
def instant_booking():
    file = request.files.get('image')
    if not file:
        return jsonify({"message": "No image uploaded"}), 400

    # Open the image
    image = Image.open(file.stream)
    image_np = np.array(image)
    
    # Run YOLO model to detect parking spots
    results = model(image_np)  # Make a prediction with YOLOv8
    boxes = results[0].boxes  # Get bounding boxes of detected objects

    # Check if any object detected is a parking spot (based on your class index)
    empty_spot_detected = False
    for box in boxes:
        if box.cls == 0:  # Replace `0` with the actual class ID of an empty spot in your model
            empty_spot_detected = True
            break

    if empty_spot_detected:
        # Generate QR code for booking receipt
        qr_code = pyqrcode.create("Parking spot detected as empty. Booking successful!")
        qr_code_img = qr_code.png_as_base64_str(scale=6)
        return jsonify({
            "message": "Parking spot detected as empty, booking successful!",
            "qr_code": qr_code_img
        }), 200
    else:
        return jsonify({"message": "No empty parking spot detected in the image"}), 400

# Route to handle booking (POST request)
@app.route('/book', methods=['POST'])
def book_parking():
    data = request.get_json()
    slot_id = data.get("slot_id")
    payment_info = data.get("payment_info")
    
    # Check if slot is available
    slot = next((s for s in parking_slots if s["slot_id"] == slot_id), None)
    if slot and slot["status"] == "Available":
        slot["status"] = "Occupied"  # Mark as booked
        slot["time"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")  # Update the time to current time
        
        # Generate QR code as receipt
        qr_code = pyqrcode.create(f"Receipt for {slot_id}, Paid with {payment_info}")
        qr_code_img = qr_code.png_as_base64_str(scale=6)
        
        # Save booking information
        bookings.append({
            "slot_id": slot_id,
            "payment_info": payment_info,
            "qr_code": qr_code_img,
            "status": "Active"
        })

        return jsonify({
            "message": "Booking confirmed",
            "receipt": {
                "slot_id": slot_id,
                "payment_info": payment_info,
                "qr_code": qr_code_img
            }
        }), 200
    else:
        return jsonify({"message": "Slot not available or invalid slot"}), 400

# Route to get current and previous bookings
@app.route('/bookings', methods=['GET'])
def get_bookings():
    return jsonify({"bookings": bookings}), 200

# Main entry point
if __name__ == '__main__':
    app.run(debug=True)
