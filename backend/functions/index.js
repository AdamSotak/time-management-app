const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Send a Firebase Message when a new CalendarEvent is created
exports.createReminder = functions.region("europe-west1").firestore.document('calendar_events/{userId}/calendar_events/{id}')
    .onCreate(async (snap, context) => {
        let calendarEvent = snap.data();
        let userId = calendarEvent.userId;
        let db = admin.firestore();

        let userToken = await db.collection("user_fcm_tokens").doc(userId).collection("user_fcm_tokens").get();
        let notificationTokens = [];

        userToken.forEach(doc => {
            notificationTokens.push(doc.data()["fcm_token"]);
        });

        const message = {
            tokens: notificationTokens,
            data: {
                action: "create",
                calendarEvent: JSON.stringify(calendarEvent)
            }
        };

        await admin.messaging().sendMulticast(message);
    });

// Send a Firebase Message when a CalendarEvent is updated
exports.updateReminder = functions.region("europe-west1").firestore.document('calendar_events/{userId}/calendar_events/{id}')
    .onUpdate(async (change, context) => {
        let calendarEvent = change.after.data();
        let userId = calendarEvent.userId;
        let db = admin.firestore();

        let userToken = await db.collection("user_fcm_tokens").doc(userId).collection("user_fcm_tokens").get();
        let notificationTokens = [];

        userToken.forEach(doc => {
            notificationTokens.push(doc.data()["fcm_token"]);
        });

        const message = {
            tokens: notificationTokens,
            data: {
                action: "update",
                calendarEvent: JSON.stringify(calendarEvent)
            }
        };

        await admin.messaging().sendMulticast(message);
    });

// Send a Firebase Message when a CalendarEvent is removed
exports.deleteReminder = functions.region("europe-west1").firestore.document('calendar_events/{userId}/calendar_events/{id}')
    .onDelete(async (snap, context) => {
        let calendarEvent = snap.data();
        let userId = calendarEvent.userId;
        let db = admin.firestore();

        let userToken = await db.collection("user_fcm_tokens").doc(userId).collection("user_fcm_tokens").get();
        let notificationTokens = [];

        userToken.forEach(doc => {
            notificationTokens.push(doc.data()["fcm_token"]);
        });

        const message = {
            tokens: notificationTokens,
            data: {
                action: "delete",
                calendarEvent: JSON.stringify(calendarEvent)
            }
        };

        await admin.messaging().sendMulticast(message);
    });

// Revoke user refresh tokens and send a logout Firebase Message
exports.revokeTokens = functions.region("europe-west1").https.onCall(async (data, context) => {
    let userId = context.auth.uid;
    admin.auth().revokeRefreshTokens(userId);
    let db = admin.firestore();

    let userToken = await db.collection("user_fcm_tokens").doc(userId).collection("user_fcm_tokens").get();
    let notificationTokens = [];

    userToken.forEach(doc => {
        notificationTokens.push(doc.data()["fcm_token"]);
    });

    const message = {
        tokens: notificationTokens,
        data: {
            action: "logout"
        }
    };

    await admin.messaging().sendMulticast(message);

    return {
        status: 200
    };
});

// Delete all user data and send a logout Firebase Message
exports.deleteUserData = functions.region("europe-west1").https.onCall(async (data, context) => {
    let userId = context.auth.uid;
    admin.auth().revokeRefreshTokens(userId);
    let db = admin.firestore();

    let userToken = await db.collection("user_fcm_tokens").doc(userId).collection("user_fcm_tokens").get();
    let notificationTokens = [];

    userToken.forEach(doc => {
        notificationTokens.push(doc.data()["fcm_token"]);
    });

    const message = {
        tokens: notificationTokens,
        data: {
            action: "logout"
        }
    };

    await admin.messaging().sendMulticast(message);

    // Todo Collections
    let todoCollectionsRef = db.collection("todo_collections").doc(userId);
    await db.recursiveDelete(todoCollectionsRef);

    // Notes
    let notesRef = db.collection("notes").doc(userId);
    await db.recursiveDelete(notesRef);

    // CalendarEvents
    let calendarEventsRef = db.collection("calendar_events").doc(userId);
    await db.recursiveDelete(calendarEventsRef);

    // User FCM tokens
    let userTokenRef = db.collection("user_fcm_tokens").doc(userId);
    await db.recursiveDelete(userTokenRef);

    // LogedInSessions
    let loggedInSessionsRef = db.collection("logged_in_sessions").doc(userId);
    await db.recursiveDelete(loggedInSessionsRef);

    const defaultBucket = admin.storage().bucket();
    defaultBucket.file(`${userId}profile`).delete();

    admin.auth().deleteUser(userId);

    return {
        status: 200
    };
});