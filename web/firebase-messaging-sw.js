importScripts("https://www.gstatic.com/firebasejs/7.5.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/7.5.0/firebase-messaging.js");
firebase.initializeApp({
    // databaseURL: "DATABASE_URL",
    apiKey: "AIzaSyCIaTQITWoSzuQRIZOL4ZhAVbleGP4sS18",
    authDomain: "availalert-22e83.firebaseapp.com",
    projectId: "availalert-22e83",
    storageBucket: "availalert-22e83.appspot.com",
    messagingSenderId: "626088962931",
    appId: "1:626088962931:web:b6f45f63315ced876fb306",
    measurementId: "G-NHK825KD5V"
});
const messaging = firebase.messaging();
// messaging.setBackgroundMessageHandler(function (payload) {
//     const promiseChain = clients
//         .matchAll({
//             type: "window",
//             includeUncontrolled: true
//         })
//         .then(windowClients => {
//             for (let i = 0; i < windowClients.length; i++) {
//                 const windowClient = windowClients[i];
//                 windowClient.postMessage(payload);
//             }
//         })
//         .then(() => {
//             return registration.showNotification("New Message");
//         });
//     return promiseChain;
// });
// messaging.setBackgroundMessageHandler(function (payload) {
//     console.log('New message found', payload)
//     const notificationTitle = payload.notification.title;
//     const notificationOptions = {
//         body: payload.notification.body,
//     };

//     return self.registration.showNotification(notificationTitle, notificationOptions);
// });
// self.addEventListener('notificationclick', function (event) {
//     console.log('notification received: ', event)
// });