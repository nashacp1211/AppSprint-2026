# 📱 MedScan

<p align="center">

![Built for AppSprint 2026](https://img.shields.io/badge/Built%20for-AppSprint%202025-7C3AED?style=for-the-badge)

![Hackathon](https://img.shields.io/badge/Hackathon-AppSprint%202025-blueviolet?style=for-the-badge)

</p>

<p align="center">
  A mobile application built during <b>AppSprint Solution Challenge 2026</b>
</p>

---

# 👥 Team Information

## Team Name

`Builders`

## Members

| Name | Role |
|---|---|
| Janna Jaleel | Developer |
| Hiba P Harshad| Designer |
| Fathima Nasha C P| Developer |
| Devika Vijikumar| Designer|

## Challenge Track

- 🏥 HealthTech


---

# 📖 Problem Statement

People often keep medicines at home but may:

Forget the expiry date of medicines.
Have difficulty identifying medicines.
Find medicine information difficult to understand.
Have medicines belonging to different family members.
Face language barriers when using health applications.
Encounter medicine packages where the expiry date cannot be clearly identified.

Using a medicine with an unknown or unverified expiry date can create a safety risk.

# 💡 Solution

MedScan is a smart household medicine management assistant that helps users safely identify, organize, and understand medicines kept at home.

How MedScan Solves the Problem

MedScan uses the phone camera and OCR technology to scan medicine packages and extract important information such as the medicine name, strength, batch number, and expiry information. The extracted information is shown to the user for verification before it is saved.

The application then evaluates the expiry information and clearly categorizes the medicine as Safe, Expiring Soon, Expiring This Month, Expired, or Expiry Unknown.

MedScan also provides general medicine information such as common uses, side effects, and warnings, helping users better understand the medicines they have at home.

Main Workflow
📷 Scan Medicine
        ↓
🔍 OCR extracts information
        ↓
✏️ User verifies / edits information
        ↓
💾 Save medicine
        ↓
⚠️ Check expiry status
        ↓
💊 View medicine information

If the expiry date cannot be detected or verified, MedScan displays Expiry Unknown instead of assuming the medicine is safe. The user is advised to verify the original packaging or consult a pharmacist/healthcare professional.

Key Innovation

The key innovation of MedScan is its safety-first expiry verification system.

Instead of simply showing an expiry date, MedScan combines:

OCR + User Verification + Expiry Intelligence + Medicine Information + Safety Handling + Multilingual Support + Family Management

A particularly important feature is the Expiry Unknown state. When the application cannot verify an expiry date, it does not classify the medicine as safe. This helps prevent users from mistakenly relying on incomplete information.

Expected Impact

MedScan aims to:

Reduce the risk of using medicines with expired or unverified expiry dates.
Make medicine information easier to access and understand.
Help households organize medicines more effectively.
Improve accessibility through multilingual support and text-to-speech.
Help family members manage medicines in one place.
Encourage safer medicine-handling decisions at home.

Overall, MedScan aims to make household medicine management safer, simpler, and more accessible.


# ✨ Features

* User authentication with Firebase
* Medicine scanning using camera and OCR
* OCR result verification and editing
* Smart medicine expiry detection
* Expiry status: Safe, Expiring Soon, Expiring This Month, Expired, and Expiry Unknown
* Safety warning for unverified or unknown expiry dates
* Medicine information including common uses, side effects, and warnings
* Prescription instruction storage
* Family member medicine management
* Multilingual support: English, Malayalam, Hindi, Tamil, and Kannada
* Cloud-based medicine data storage using Firebase


# 📱 Screenshots
The following screenshots demonstrate the main features and user flow of MedScan.

### Application Screenshots

- `assets/screenshots/start.png`
- `assets/screenshots/login.png`
- `assets/screenshots/home.png`
- `assets/screenshots/scanmedicine.png`
- `assets/screenshots/language.png`
- `assets/screenshots/addmedicine.png`
- `assets/screenshots/add.png`


# 🎥 Demo Video

Add your demo video link.

Example:

```
https://youtube.com/your-demo-link
```

Demo duration:

**Maximum: 2 minutes**

Your video should show:

- Problem
- Solution
- Main features
- App workflow

---

# 📦 APK Download

Upload your APK using GitHub Releases.

Add your release link below:

```
https://github.com/YOUR_USERNAME/YOUR_REPOSITORY/releases
```

---

# 🛠️ Tech Stack

## Frontend / Mobile Framework

* Flutter + Dart

## Backend

* Firebase

  * Firebase Authentication
  * Firebase Cloud Firestore
  * Firebase Storage

## Database

* Cloud Firestore

## APIs / Services Used

* Google ML Kit Text Recognition — Medicine package OCR and text extraction
* RxNorm API — Medicine identification and standardized medicine information
* FDA openFDA API — Medicine uses, side effects, and warnings
* Flutter Text-to-Speech — Accessibility and read-aloud support
* Image Picker / Camera — Capturing medicine package images


# 🚀 Installation

## Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
```

## Navigate to Project

```bash
cd YOUR_PROJECT_NAME
```

## Install Dependencies

### Flutter

```bash
flutter pub get
```

### React Native

```bash
npm install
```

## Run Application

### Flutter

```bash
flutter run
```

### React Native

```bash
npm start
```

---

# 📂 Project Structure

Explain your project structure.

Example:

```
project/
│
├── assets/
├── lib/
├── screens/
├── widgets/
├── services/
└── README.md
```

---

# 🌟 Key Highlights

Mention what makes your project special.

Examples:

- Unique approach
- Technical challenges solved
- Innovation
- Real-world usability

---

# 🔮 Future Improvements

Features planned for future versions:

- Feature 1
- Feature 2
- Feature 3

---

# 📊 Impact

Explain the expected impact of your application.

Include:

- Target users
- Benefits
- Social/community impact

---

# 📜 License

This project is licensed under the MIT License.

---

# 🏆 AppSprint Solution Challenge 2026

Built with ❤️ during **AppSprint Solution Challenge 2026**

Organized by:

**App Development IG · muLearn LBSITW**

---
