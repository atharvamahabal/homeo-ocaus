// Firebase Configuration
const firebaseConfig = {
    apiKey: "AIzaSyAteRekm_YdYUhm4dhHvgwXY4gam_3OywM",
    authDomain: "homeo-ocaus.firebaseapp.com",
    projectId: "homeo-ocaus",
    storageBucket: "homeo-ocaus.firebasestorage.app",
    messagingSenderId: "1098453998984",
    appId: "1:1098453998984:web:00d077893bbf71a7756e3d",
    measurementId: "G-KL8BK59BW5"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();
const googleProvider = new firebase.auth.GoogleAuthProvider();
