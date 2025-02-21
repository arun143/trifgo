importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyBdCZwjD5sUVabsPjn9rnDJ-UHCLuFsHMI",
            authDomain: "streaks-11c35.firebaseapp.com",
            projectId: "streaks-11c35",
            storageBucket: "streaks-11c35.firebasestorage.app",
            messagingSenderId: "492501400115",
            appId: "1:492501400115:web:a59b72cc898c4696330146",
            measurementId: "G-P99HGTT75N"
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});