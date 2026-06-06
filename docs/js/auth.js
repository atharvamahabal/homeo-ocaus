const loginForm = document.getElementById('login-form');
const signupForm = document.getElementById('signup-form');
const linkSignup = document.getElementById('link-signup');
const linkLogin = document.getElementById('link-login');
const loadingOverlay = document.getElementById('loading-overlay');

// UI Toggles
linkSignup.onclick = (e) => {
    e.preventDefault();
    loginForm.classList.add('hidden');
    signupForm.classList.remove('hidden');
    document.getElementById('auth-title').innerText = "Join Homeo-Ocaus";
};

linkLogin.onclick = (e) => {
    e.preventDefault();
    signupForm.classList.add('hidden');
    loginForm.classList.remove('hidden');
    document.getElementById('auth-title').innerText = "Homeo-Ocaus";
};

// Authentication Logic
document.getElementById('btn-login').onclick = async () => {
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    
    if(!email || !password) return alert("Please enter email and password");

    showLoading(true);
    try {
        const userCredential = await auth.signInWithEmailAndPassword(email, password);
        handleUserRoute(userCredential.user.uid);
    } catch (error) {
        alert(error.message);
        showLoading(false);
    }
};

document.getElementById('btn-google').onclick = async () => {
    showLoading(true);
    try {
        const result = await auth.signInWithPopup(googleProvider);
        handleUserRoute(result.user.uid);
    } catch (error) {
        alert(error.message);
        showLoading(false);
    }
};

document.getElementById('btn-register').onclick = async () => {
    const name = document.getElementById('signup-name').value;
    const email = document.getElementById('signup-email').value;
    const password = document.getElementById('signup-password').value;
    const role = document.getElementById('signup-role').value;

    if(!name || !email || !password) return alert("Fill all fields");

    showLoading(true);
    try {
        const userCredential = await auth.createUserWithEmailAndPassword(email, password);
        const uid = userCredential.user.uid;
        
        // Save profile to Firestore (Mirroring Flutter logic)
        await db.collection('users').doc(uid).set({
            name: name,
            email: email,
            role: role,
            createdAt: firebase.firestore.FieldValue.serverTimestamp()
        });

        handleUserRoute(uid);
    } catch (error) {
        alert(error.message);
        showLoading(false);
    }
};

async function handleUserRoute(uid) {
    const doc = await db.collection('users').doc(uid).get();
    if (doc.exists) {
        const role = doc.data().role;
        if (role === 'doctor') {
            window.location.href = 'doctor.html';
        } else {
            window.location.href = 'patient.html';
        }
    } else {
        // Default to patient if no profile
        window.location.href = 'patient.html';
    }
}

function showLoading(show) {
    if(show) loadingOverlay.classList.remove('hidden');
    else loadingOverlay.classList.add('hidden');
}

// Check if already logged in
auth.onAuthStateChanged(user => {
    if (user) {
        handleUserRoute(user.uid);
    }
});
