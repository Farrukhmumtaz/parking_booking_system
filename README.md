
# Parking Booking System

A Parking Booking System integrating a **Flask Backend** and a **Flutter-based Frontend**, enabling users to book parking slots, perform instant bookings, and generate QR codes for receipts.

---

## Features

### Backend
- Built with **Flask**.
- Provides API endpoints for:
  - User login and account creation.
  - Retrieving parking slot availability.
  - Booking slots with payment and receipt generation.
  - Instant booking using image uploads.
- Simulated parking slot availability.

### Frontend
- Built with **Flutter**.
- Includes:
  - Login and signup pages.
  - Home page with parking slot information.
  - Instant booking using an image upload.
  - Downloadable QR code receipts.

---

## Tech Stack

- **Backend**: Python, Flask, PyQRCode
- **Frontend**: Flutter, Dart
- **Database**: JSON Simulation

---

## Installation

### Backend
1. Clone the repository and navigate to the backend folder.
2. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```
3. Start the Flask server:
   ```bash
   python app.py
   ```

### Frontend
1. Navigate to the frontend folder.
2. Install Flutter and fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the Flutter app:
   ```bash
   flutter run
   ```

---

## API Endpoints

| Method | Endpoint           | Description                            |
|--------|--------------------|----------------------------------------|
| POST   | `/login`           | Authenticates user credentials.        |
| POST   | `/create_account`  | Creates a new account.                 |
| GET    | `/slots`           | Fetches parking slot availability.     |
| POST   | `/book`            | Books a specific parking slot.         |
| GET    | `/instant_booking` | Books using image upload and detection.|

---

## Usage

1. **Login**: Use the default admin account or create a new user.
2. **View Slots**: Check the availability of parking slots.
3. **Book a Slot**: Use the booking button or instant booking feature.
4. **Save Receipt**: Download the QR code for future reference.

---

## Default Admin Account

| **Username** | **Password** |
|--------------|--------------|
| `admin`      | `admin123`   |

---

## Contributing

1. Fork the repo.
2. Create a branch:
   ```bash
   git checkout -b feature-name
   ```
3. Commit changes:
   ```bash
   git commit -m "Added new feature"
   ```
4. Push the branch:
   ```bash
   git push origin feature-name
   ```
5. Submit a pull request.

---

## License

This project is licensed under the MIT License.

---

**Developed by Farrukh Mumtaz**
