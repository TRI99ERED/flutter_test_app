importScripts('https://www.gstatic.com/firebasejs/10.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging-compat.js');

firebase.initializeApp({
    apiKey: "AIzaSyDTBMsIRoCktgyNCy8gwjEWt2fCrvNvhMc",
    authDomain: "test-app-fd3aa.firebaseapp.com",
    projectId: "test-app-fd3aa",
    storageBucket: "test-app-fd3aa.firebasestorage.app",
    messagingSenderId: "503645418605",
    appId: "1:503645418605:web:db3f180c549e3a78e0fb64",
    measurementId: "G-4EP2PEHVZB"
});

const messaging = firebase.messaging();
