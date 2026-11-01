# Telemedicine API (backend)

Node.js 20+ · Express 5 · MongoDB (Mongoose 8)

## Setup
```bash
npm install
cp .env.example .env
npm run dev        # development (auto-reload)
npm start          # production
```
Health check: `GET /health`

## Environment (`.env`)
| Variable | Purpose |
|---|---|
| `PORT`, `MONGODB_URI` | Server port and database |
| `FIREBASE_PROJECT_ID`, `GOOGLE_APPLICATION_CREDENTIALS` | Push notifications (service account JSON, not committed) |
| `SMTP_EMAIL`, `SMTP_PASSWORD` | Password-reset emails (Gmail app password) |
| `ADMIN_JWT_SECRET` | Signs admin logins and seals push tokens |
| `SEED_ADMIN_*` | Main admin created by `npm run seed:admins` |

## Scripts
- `npm run seed:admins` creates the main admin (`-- --reset` resets its password)
- `npm run create-admin -- --name ... --phone ... --email ... --password ...`

## Notes
- App API responses never include passwords; push tokens are sent to apps only in sealed (encrypted) form.
- Calls are tracked on the server (`/call_start`, `/call_update`, `/call_status`, `/call_incoming`), so declining or ending a call works even without push.
