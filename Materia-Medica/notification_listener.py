import firebase_admin
from firebase_admin import credentials, messaging, firestore
import os
import time
import threading
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def start_notification_listener():
    """
    Listens to Firestore 'notifications' collection and sends real FCM push notifications.
    This replaces the need for paid Firebase Cloud Functions.
    """
    # 1. Initialize Firebase Admin
    # Note: Requires serviceAccountKey.json in the same folder
    cert_path = os.path.join(os.path.dirname(__file__), "serviceAccountKey.json")
    
    if not os.path.exists(cert_path):
        print("\n" + "!"*60)
        print("ERROR: serviceAccountKey.json NOT FOUND!")
        print("To enable real-time notifications without a paid plan, please:")
        print("1. Go to Firebase Console -> Project Settings -> Service Accounts")
        print("2. Click 'Generate new private key'")
        print(f"3. Rename the file to 'serviceAccountKey.json' and place it in: {os.path.dirname(__file__)}")
        print("!"*60 + "\n")
        return

    try:
        cred = credentials.Certificate(cert_path)
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("✅ Firebase Admin initialized. Listening for notifications...")
    except Exception as e:
        print(f"❌ Error initializing Firebase Admin: {e}")
        return

    # 2. Define the callback for Firestore snapshots
    def on_snapshot(col_snapshot, changes, read_time):
        for change in changes:
            if change.type.name == 'ADDED':
                doc = change.document
                data = doc.to_dict()
                
                # Only process 'pending' notifications
                if data.get('status') == 'pending':
                    recipient_id = data.get('recipientId')
                    title = data.get('title', 'New Notification')
                    body = data.get('body', '')
                    extra_data = data.get('data', {})
                    
                    if not recipient_id:
                        continue
                        
                    print(f"🔔 Processing notification for: {recipient_id}")
                    
                    try:
                        # 3. Get FCM Token for the recipient
                        token_doc = db.collection('fcm_tokens').document(recipient_id).get()
                        if not token_doc.exists:
                            print(f"⚠️ No FCM token found for user: {recipient_id}")
                            # Mark as failed so we don't keep trying
                            doc.reference.update({'status': 'no_token_found'})
                            continue
                            
                        fcm_token = token_doc.to_dict().get('token')
                        
                        # 4. Construct and send FCM Message
                        message = messaging.Message(
                            notification=messaging.Notification(
                                title=title,
                                body=body,
                            ),
                            data={str(k): str(v) for k, v in extra_data.items()}, # Ensure all values are strings
                            token=fcm_token,
                        )
                        
                        response = messaging.send(message)
                        print(f"🚀 Successfully sent push notification: {response}")
                        
                        # 5. Mark as sent
                        doc.reference.update({
                            'status': 'sent',
                            'sentAt': firestore.SERVER_TIMESTAMP,
                            'fcmMessageId': response
                        })
                        
                    except Exception as e:
                        print(f"❌ Error sending notification: {e}")
                        doc.reference.update({'status': 'error', 'error': str(e)})

    # 3. Start watching the collection
    col_query = db.collection('notifications').where('status', '==', 'pending')
    query_watch = col_query.on_snapshot(on_snapshot)

    # Keep the thread alive
    while True:
        time.sleep(1)

if __name__ == "__main__":
    start_notification_listener()
