# Tayo · Telemedicine Somalia

A telemedicine platform that connects patients with doctors in Somalia: book appointments, pay, and consult by voice or video call.

| Folder | What it is |
|---|---|
| `tele/` | Flutter mobile app for patients and doctors (Android / iOS) |
| `backend/` | Node.js REST API (Express 5, MongoDB / Mongoose 8) |

## Features
- Doctor search by hospital and speciality, shifts and appointment booking
- Voice and video consultations (ZEGOCLOUD) with full-screen incoming calls, even when the app is closed
- Push notifications (Firebase Cloud Messaging, sent only from the server)
- Prescriptions, lab requests and lab results
- Payments (WaafiPay EVC Plus; mock mode for testing)
- English and Somali

## Quick start

**Backend**
```bash
cd backend
npm install
cp .env.example .env        # fill in MongoDB, Firebase, SMTP, admin values
npm run dev                 # http://localhost:2003
```
Place the Firebase service account file at `backend/serviceAccountKey.json`.

**App**
```bash
cd tele
cp .env.example .env        # API address, ZEGOCLOUD, Firebase, payment mode
flutter pub get
flutter run
```
Place `google-services.json` in `tele/android/app/`. The API address can also be changed in the app (login screen → server icon).

**Release APK**
```bash
flutter build apk --release --split-per-abi
```

## Secrets
Never commit `.env`, `serviceAccountKey.json` or `google-services.json` (already in `.gitignore`). Only the `.env.example` templates are tracked.

## Research
*Developing a Context-Aware Telemedicine Platform to Improve Healthcare Accessibility in Somalia*. Faculty of Computer and Information Technology, Jamhuriya University of Science and Technology (JUST), Mogadishu.

## License
MIT
