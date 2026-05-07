importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyCDXN_bquCWL8tacoUaV5wSW-QAIISLdSc",
  authDomain: "carwash-go-a8adc.firebaseapp.com",
  projectId: "carwash-go-a8adc",
  storageBucket: "carwash-go-a8adc.firebasestorage.app",
  messagingSenderId: "679309022789",
  appId: "1:679309022789:web:17d6e17186b3daf3bbb52c",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('Background Message:', payload);

  self.registration.showNotification(
    payload.notification.title,
    {
      body: payload.notification.body,
      icon: '/icons/Icon-192.png',
    }
  );
});