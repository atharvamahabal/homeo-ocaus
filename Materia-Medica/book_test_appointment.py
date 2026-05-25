import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta
import uuid
import os

# 1. Initialize Firebase Admin
from dotenv import load_dotenv
import json
load_dotenv()

service_account_json = os.getenv("FIREBASE_SERVICE_ACCOUNT")
if service_account_json:
    service_account_info = json.loads(service_account_json)
    cred = credentials.Certificate(service_account_info)
else:
    cert_path = os.path.join(os.path.dirname(__file__), "serviceAccountKey.json")
    if not os.path.exists(cert_path):
        print("Error: FIREBASE_SERVICE_ACCOUNT env var or serviceAccountKey.json not found.")
        exit()
    cred = credentials.Certificate(cert_path)

if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)

db = firestore.client()

def book_test_appointment():
    patient_id = "test_patient_123"
    patient_name = "John Doe"
    doctor_id = "dr_tanaya"
    doctor_name = "Dr Tanaya"
    health_concern = "Severe headache and cold"
    
    # 2. Ensure Patient Profile exists
    patient_ref = db.collection('patients').document(patient_id)
    if not patient_ref.get().exists:
        print(f"Creating test patient profile: {patient_name}")
        patient_ref.set({
            'id': patient_id,
            'name': patient_name,
            'email': 'test_patient@example.com',
            'phoneNumber': '+91 9876543210',
            'createdAt': firestore.SERVER_TIMESTAMP
        })

    # 3. Create Appointment
    appointment_id = str(uuid.uuid4())
    appointment_time = datetime.now() + timedelta(days=1)
    
    appointment_data = {
        'id': appointment_id,
        'patientId': patient_id,
        'doctorId': doctor_id,
        'doctorName': doctor_name,
        'dateTime': appointment_time.isoformat(),
        'status': 'pending',
        'type': 'clinic',
        'healthConcern': health_concern,
        'isPaid': False,
        'amount': 500.0
    }
    
    print(f"Booking appointment: {appointment_id}")
    db.collection('appointments').document(appointment_id).set(appointment_data)

    # 4. Create Notification record (this triggers the Python listener we built)
    notification_data = {
        'recipientId': doctor_id,
        'title': 'New Appointment Booking',
        'body': f'{patient_name} has booked an appointment regarding: {health_concern}',
        'data': {
            'type': 'new_appointment',
            'appointmentId': appointment_id,
            'patientId': patient_id,
        },
        'status': 'pending',
        'createdAt': firestore.SERVER_TIMESTAMP
    }
    
    print(f"Triggering notification for {doctor_id}...")
    db.collection('notifications').add(notification_data)
    
    print("\n✅ Success!")
    print(f"Appointment booked for {patient_name} on {appointment_time.strftime('%Y-%m-%d %H:%M')}")
    print("If your 'remedy_ai_backend.py' is running, you should see the notification trigger now!")

if __name__ == "__main__":
    book_test_appointment()
