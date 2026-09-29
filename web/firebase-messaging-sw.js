// 1. Use the compat versions to ensure 'firebase' global is defined
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// 2. Initialize
firebase.initializeApp({
    apiKey: "AIzaSyDevY_5B7lJZkFyiC6rZrqp2vwEzZm4tYE",
    authDomain: "dtlive-541ce.firebaseapp.com",
    projectId: "dtlive-541ce",
    storageBucket: "dtlive-541ce.firebasestorage.app",
    messagingSenderId: "303674087931",
    appId: "1:303674087931:web:7b31081bd2e4ae7677135e",
});

// 3. Retrieve Messaging
const messaging = firebase.messaging();

// 4. Background handler
messaging.onBackgroundMessage((payload) => {
    console.log('Received background message ', payload);
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/favicon.png'
    };
    self.registration.showNotification(notificationTitle, notificationOptions);
});
