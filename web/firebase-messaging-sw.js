self.addEventListener('install', (event) => {
  event.waitUntil(
    fetch('/firebase-config.json') // Load config from a secure file
      .then(response => response.json())
      .then(config => {
        importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
        importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

        firebase.initializeApp(config);
        const messaging = firebase.messaging();

        messaging.onBackgroundMessage(function (payload) {
          console.log('Received background message: ', payload);
          self.registration.showNotification(payload.notification.title, {
            body: payload.notification.body,
            icon: "/firebase-logo.png"
          });
        });
      })
  );
});
