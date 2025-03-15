importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCPDruIF3PUNUemrXWVX_H1TECAll8dJec",
  authDomain: "offline-14ce6.firebaseapp.com",
  projectId: "offline-14ce6",
  storageBucket: "offline-14ce6.firebasestorage.app",
  messagingSenderId: "243295987001",
  appId: "1:243295987001:web:2e6cce918237ee735174e8",
  measurementId: "G-RTYXPH7TRY"
});
firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

/*messaging.onMessage((payload) => {
console.log('Message received. ', payload);*/
messaging.onBackgroundMessage(function (payload) {
  console.log('Received background message ', payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
  };

  self.registration.showNotification(notificationTitle,
    notificationOptions);
});