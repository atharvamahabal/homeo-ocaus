const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Triggered when a new document is added to the 'notifications' collection.
 * This sends a real push notification to the recipient's device via FCM.
 */
exports.sendPushNotification = onDocumentCreated("notifications/{notificationId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        console.log("No data associated with the event");
        return;
    }

    const data = snapshot.data();
    const recipientId = data.recipientId;
    const title = data.title || "New Notification";
    const body = data.body || "";
    const extraData = data.data || {};

    if (!recipientId) {
        console.log("No recipientId found in notification document");
        return;
    }

    try {
        // 1. Get the recipient's FCM token from Firestore
        // The token is saved by the mobile app in the 'fcm_tokens' collection
        const tokenDoc = await admin.firestore().collection("fcm_tokens").doc(recipientId).get();
        
        if (!tokenDoc.exists) {
            console.log(`No FCM token found for user: ${recipientId}`);
            return;
        }

        const token = tokenDoc.data().token;

        // 2. Construct the FCM message
        const message = {
            notification: {
                title: title,
                body: body,
            },
            data: {
                ...extraData,
                // These help the Flutter app handle the tap
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                status: "done",
            },
            token: token,
        };

        // 3. Send the notification via FCM
        const response = await admin.messaging().send(message);
        console.log("Successfully sent push notification:", response);

        // 4. Mark the notification document as 'sent'
        return snapshot.ref.update({
            status: "sent",
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            fcmMessageId: response
        });

    } catch (error) {
        console.error("Error sending push notification:", error);
    }
});
