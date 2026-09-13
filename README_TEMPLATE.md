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
<img width="702" height="1600" alt="scanmedicine" src="https://github.com/user-attachments/assets/dd57a418-545c-403d-9d15-01200d770c23" />
<img width="720" height="1640" alt="start" src="https://github.com/user-attachments/assets/6ec994e0-33f2-4516-9b16-61c37ab97724" />
<img width="720" height="1640" alt="language" src="https://github.com/user-attachments/assets/400e9d86-f058-4b17-a807-2e685f8da189" />
<img width="720" height="1640" alt="login" src="https://github.com/user-attachments/assets/a2d18c84-7c65-4bce-9852-c0d9b535090c" />
<img width="720" height="1640" alt="addmedicine" src="https://github.com/user-attachments/assets/d2ec6602-bb4e-4af0-8e3d-faca11d2a1ec" />



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
https://github.com/nashacp1211/AppSprint-2026/releases
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
git clone https://github.com/nashacp1211/AppSprint-2026.git
```

## Navigate to the MedScan Project

```bash
cd AppSprint-2026/med_scan
```

## Install Dependencies

Make sure Flutter is installed, then run:

```bash
flutter pub get
```

## Check Flutter Setup

```bash
flutter doctor
```

Make sure the required Android tools and connected device/emulator are available.

## Run MedScan

Connect an Android phone or start an Android emulator, then run:

```bash
flutter run
```

Flutter will build and launch the MedScan application on the connected device.

## Run on Chrome for Testing

For development/testing, MedScan can also be run on Chrome:

```bash
flutter run -d chrome
```

## Build APK

To generate an Android APK for installation or competition submission:

```bash
flutter build apk --release
```

The generated APK can be found at:

```text
build/app/outputs/flutter-apk/app-release.apk
```


# 📂 Project Structure

## Project Structure

```text
med_scan/
│
├── assets/
│   └── icon/
│       └── med_scan.png
│
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── medicine.dart
│   │
│   ├── screens/
│   │   ├── medicine_verification.dart
│   │   └── expiry_result.dart
│   │
│   └── services/
│       ├── ocr_service.dart
│       └── expiry_service.dart
│
├── android/
├── ios/
├── web/
│
├── pubspec.yaml
└── README.md
```

### Main Components

* **assets/** – Contains application resources such as the MedScan app icon.
* **lib/main.dart** – The main entry point of the Flutter application and the home dashboard.
* **models/** – Contains the `Medicine` data model used to store medicine information.
* **screens/** – Contains the application's user interface screens, including medicine verification and expiry status.
* **services/** – Contains the application's core logic, such as OCR scanning and expiry-date analysis.
* **android/** – Contains Android-specific project files required to build and run the application.
* **ios/** – Contains iOS-specific project files.
* **web/** – Contains files required for running the Flutter application on the web during development/testing.
* **pubspec.yaml** – Defines the Flutter project, dependencies, assets, and configuration.
* **README.md** – Contains project documentation, features, setup instructions, screenshots, and competition information.

### Application Flow

```text
main.dart
    │
    ├── Camera / OCR
    │       ↓
    │   ocr_service.dart
    │       ↓
    ├── Medicine Verification
    │       ↓
    │   medicine.dart
    │       ↓
    └── Expiry Analysis
            ↓
       expiry_service.dart
            ↓
      Expiry Result Screen
```

This structure keeps the **UI, data models, and application logic separated**, making MedScan easier to develop, test, and maintain.


# 🌟 Key Highlights

## What Makes MedScan Special

* **Safety-First Approach** – MedScan does not assume a medicine is safe when its expiry date cannot be verified. It clearly marks it as **“Expiry Unknown”** and advises the user to verify the original packaging or consult a pharmacist.

* **OCR + User Verification** – The camera and OCR automatically extract medicine information, but the user can **review and correct the information before it is saved**, reducing errors caused by imperfect scanning.

* **Smart Expiry Intelligence** – Medicines are categorized into **Safe, Expiring Soon, Expiring This Month, Expired, and Expiry Unknown**, making expiry information easy to understand.

* **Accessible Health Information** – MedScan combines medicine identification with common uses, side effects, warnings, multilingual support, and text-to-speech.

* **Real-World Usability** – Instead of being designed only for hospitals, MedScan focuses on a common household problem: **managing medicines safely at home**.

* **Technical Innovation** – The application combines **Flutter, Google ML Kit OCR, Firebase, medicine information APIs, multilingual support, and accessibility features** into one mobile solution.

### Key Innovation

The strongest innovation is the combination of **OCR + human verification + safety-first expiry handling**. MedScan is designed not just to read a medicine package, but to help users make safer decisions about medicines kept at home.


# 🔮 Future Improvements

## Features Planned for Future Versions

* **AI-Powered Medicine Recognition** – Improve medicine identification from images, including difficult-to-read or partially visible packaging.
* **Smart Family Health Management** – Add advanced family profiles and personalized medicine organization for different family members.
* **Pharmacy & Healthcare Integration** – Connect users with nearby pharmacies and healthcare professionals for medicine replacement, verification, and safer disposal guidance.


# 📊 Impact

## Expected Impact

### Target Users

MedScan is mainly designed for:

* Families and households that keep medicines at home.
* Elderly people and people who manage multiple medicines.
* Caregivers who manage medicines for children, parents, or other family members.
* Users who prefer information in regional languages.

### Benefits

* Helps users identify and track medicine expiry dates.
* Reduces the risk of accidentally using expired or unverified medicines.
* Saves time by using camera-based OCR to capture medicine information.
* Allows users to verify and correct scanned information before saving.
* Provides useful information such as common uses, side effects, and warnings.
* Keeps prescription instructions organized in one place.
* Supports multiple languages and text-to-speech for better accessibility.
* Helps families manage medicines more safely and efficiently.

### Social and Community Impact

MedScan can promote safer medicine-handling habits at the household level. It can be especially useful for families caring for elderly members or people who take multiple medicines.

By making medicine information easier to understand and highlighting medicines with expired or unknown expiry dates, MedScan can help increase awareness about medicine safety and reduce avoidable risks caused by poor medicine management.

The application also promotes **digital health awareness, accessibility, and responsible medicine use** within the community.


# 📜 License

This project is licensed under the MIT License.

---

# 🏆 AppSprint Solution Challenge 2026

Built with ❤️ during **AppSprint Solution Challenge 2026**

Organized by:

**App Development IG · muLearn LBSITW**

---
