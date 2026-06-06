# GitHub Pages Deployment Guide for Homeo-Ocaus

This project contains a standalone web version of the Homeo-Ocaus Clinic Management System, located in the `docs/` folder. This version is built with vanilla HTML, CSS, and JavaScript to be compatible with GitHub Pages.

## Deployment Steps

1. **Push to GitHub**:
   Ensure your latest changes are pushed to your GitHub repository.

2. **Enable GitHub Pages**:
   - Go to your repository on GitHub.
   - Click on **Settings** (top tab).
   - In the left sidebar, click **Pages**.
   - Under **Build and deployment > Source**, select **Deploy from a branch**.
   - Under **Branch**, select `main` (or your primary branch) and set the folder to `/docs`.
   - Click **Save**.

3. **Configure Firebase**:
   - Go to the [Firebase Console](https://console.firebase.google.com/).
   - Go to **Project Settings > General**.
   - Under **Your apps**, ensure you have a "Web app" added.
   - Copy the configuration object and update `docs/js/firebase-config.js` if necessary.
   - Go to **Authentication > Settings > Authorized domains** and add your GitHub Pages domain (e.g., `your-username.github.io`).

4. **Configure Google Sign-In**:
   - In the Firebase Console, go to **Authentication > Sign-in method**.
   - Ensure **Google** is enabled.
   - Under **Web SDK configuration**, ensure the Web Client ID matches what is used in the app.

5. **Access the Site**:
   Once the GitHub Pages build is complete (check the **Actions** tab), your site will be available at `https://your-username.github.io/homeo-ocaus/`.

## Features Included
- **Authentication**: Login, Signup, and Google Sign-In.
- **Doctor Dashboard**: Manage pending appointments and access AI tools.
- **Patient Dashboard**: View appointments and book new ones.
- **AI Remedy Assistant**:
    - Standard Chat Mode for symptom description.
    - **Classical Repertory Mode**: Input 3-5 symptoms to find the best-fitting remedy.
    - Dynamic Backend IP configuration (via the ⚙️ icon) to connect to your local AI server.

## Note on AI Backend
The AI Chatbot requires the Python backend to be running. Since GitHub Pages is a static host, you must run the backend locally or on a server and configure the IP address in the web app's settings dialog.
