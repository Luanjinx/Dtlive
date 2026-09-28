// 1. Use the compat versions to ensure 'firebase' global is defined
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// 2. Initialize
firebase.initializeApp({
    apiKey: "AIzaSyDH7SLoHkaSkvn8PSFbfi4P_zYUZjsZQvQ",
    authDomain: "streamit-7bbe3.firebaseapp.com",
    projectId: "streamit-7bbe3",
    storageBucket: "streamit-7bbe3.firebasestorage.app",
    messagingSenderId: "773450355985",
    appId: "1:773450355985:web:27537a2b6ca4ea600ce8b0"
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
