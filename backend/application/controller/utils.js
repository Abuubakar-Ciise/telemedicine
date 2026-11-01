// Shared helpers for the API.
const fs = require('fs');
const path = require('path');
const axios = require('axios');
const nodemailer = require('nodemailer');
const { GoogleAuth } = require('google-auth-library');
const { customAlphabet } = require('nanoid');

const UPLOADS_DIR = path.join(__dirname, '..', '..', 'uploads');

function getImageFolderName(nameId) {
  switch (nameId) {
    case 1:
      return 'admin_profile/';
    default:
      return '';
  }
}

exports.getImageFolderName = getImageFolderName;

exports.saveImageFolderPath = function (nameId) {
  return path.join(UPLOADS_DIR, getImageFolderName(nameId));
};

exports.deleteImageFromFolderTosaveNewOne = function (oldImgPath, nameId) {
  if (!oldImgPath) return;
  const fileName = String(oldImgPath).split('/').pop();
  fs.unlink(path.join(exports.saveImageFolderPath(nameId), fileName), () => {});
};

// Unique id with prefix 07300
exports.get_unique_id = function () {
  const nanoid = customAlphabet('123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ', 5);
  return '07300' + nanoid();
};

exports.get_otp_number = function (length = 4) {
  const possible = '123456789';
  let otp = '';
  for (let i = 0; i < length; i++) otp += possible.charAt(Math.floor(Math.random() * possible.length));
  return otp;
};

exports.tokenGenerator = function (length = 32) {
  const possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let token = '';
  for (let i = 0; i < length; i++) token += possible.charAt(Math.floor(Math.random() * possible.length));
  return token;
};

// ---------------- Email (password reset OTP) ----------------
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: { user: process.env.SMTP_EMAIL, pass: process.env.SMTP_PASSWORD },
});

exports.send_email_otp = function (req, email, msg) {
  if (!process.env.SMTP_EMAIL || !process.env.SMTP_PASSWORD) {
    console.warn('SMTP_EMAIL / SMTP_PASSWORD not set - OTP email not sent');
    return;
  }
    const htmlTemplate = `
      <div style="max-width:520px;margin:40px auto;border-radius:14px;box-shadow:0 4px 24px rgba(0,0,0,0.08);border:1px solid #e0e7ef;padding:36px 40px 32px 40px;background:#fff;font-family:'Segoe UI',sans-serif;">
          <div style="text-align:center;">
              <img src="https://img.icons8.com/color/96/000000/health-checkup.png" alt="Telemedicine Somalia" style="width:64px;height:64px;margin-bottom:12px;">
              <h2 style="color:#1a73e8;margin-bottom:8px;font-weight:600;">Telemedicine Somalia</h2>
              <div style="font-size:20px;color:#222;font-weight:500;margin-bottom:18px;">Password Reset Request</div>
          </div>
          <p style="font-size:16px;color:#444;margin-bottom:18px;">
              Hello,<br>
              We received a request to reset your password. Please use the OTP below to continue:
          </p>
          <div style="text-align:center;margin:32px 0;">
              <span style="display:inline-block;font-size:36px;letter-spacing:10px;background:#f0f7ff;padding:18px 36px;border-radius:10px;color:#1a73e8;font-weight:bold;box-shadow:0 2px 8px rgba(26,115,232,0.08);">
                  ${msg.replace(/\D/g, '') || msg}
              </span>
          </div>
          <p style="font-size:15px;color:#666;margin-bottom:0;">
              <b>Note:</b> This OTP is valid for a limited time and can only be used once.<br>
              If you did not request a password reset, please ignore this email or contact support.
          </p>
          <div style="margin-top:32px;text-align:center;">
              <span style="font-size:15px;color:#888;">Thank you,<br><b>Telemedicine Somalia Team</b></span>
          </div>
      </div>
  `;

  transporter.sendMail(
    {
      from: process.env.SMTP_EMAIL,
      to: email,
      subject: 'Telemedicine Somalia Password Reset OTP',
      text: msg,
      html: htmlTemplate,
    },
    (error) => {
      if (error) console.error('Email send error:', error.message);
    }
  );
};

// ---------------- Push notifications (FCM HTTP v1) ----------------
const auth = new GoogleAuth({
  keyFile: process.env.GOOGLE_APPLICATION_CREDENTIALS || path.join(process.cwd(), 'serviceAccountKey.json'),
  scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
});

/**
 * Send push notification to a device using FCM.
 * @param {Object} data - { token, title, message, [dataPayload] }
 * @param {Function} callback - function(err, response)
 */
exports.send_notification = async function (data, callback) {
  try {
    const client = await auth.getClient();
    const accessToken = await client.getAccessToken();
    const url = `https://fcm.googleapis.com/v1/projects/${process.env.FIREBASE_PROJECT_ID}/messages:send`;

    const response = await axios.post(
      url,
      {
        message: {
          token: data.token,
          notification: { title: data.title || 'Notification', body: data.message || '' },
          android: {
            priority: 'high',
            notification: { click_action: 'FLUTTER_NOTIFICATION_CLICK', channel_id: 'default_channel' },
          },
          data: data.dataPayload || {},
        },
      },
      { headers: { Authorization: `Bearer ${accessToken.token}`, 'Content-Type': 'application/json' } }
    );
    if (callback) callback(null, response.data);
  } catch (err) {
    console.error('FCM send error:', err.response?.data?.error?.message || err.message);
    if (callback) callback(err, null);
  }
};

/**
 * Send a full FCM v1 `message` object (built by the mobile app) through the server.
 * The service account key stays on the server and is never shipped inside the app.
 */
exports.send_fcm_message = async function (message) {
  const client = await auth.getClient();
  const accessToken = await client.getAccessToken();
  const url = `https://fcm.googleapis.com/v1/projects/${process.env.FIREBASE_PROJECT_ID}/messages:send`;
  const response = await axios.post(
    url,
    { message },
    { headers: { Authorization: `Bearer ${accessToken.token}`, 'Content-Type': 'application/json' } }
  );
  return response.data;
};

// ---------------- Sealed push tokens ----------------
// Device push tokens are never sent to apps in plain text. API responses carry a
// "sealed" (AES-256-GCM encrypted) copy; only this server can open it in /send_push.
const crypto = require('crypto');
const SEALED_PREFIX = 'sealed:';
function tokenKey() {
  const secret = process.env.PUSH_TOKEN_SECRET || process.env.ADMIN_JWT_SECRET || 'telemedicine-push-token-key';
  return crypto.createHash('sha256').update('push-token:' + secret).digest();
}

exports.sealToken = function (token) {
  if (!token || typeof token !== 'string' || token.startsWith(SEALED_PREFIX)) return token;
  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv('aes-256-gcm', tokenKey(), iv);
  const data = Buffer.concat([cipher.update(token, 'utf8'), cipher.final()]);
  return SEALED_PREFIX + Buffer.concat([iv, cipher.getAuthTag(), data]).toString('base64url');
};

exports.unsealToken = function (value) {
  if (!value || typeof value !== 'string' || !value.startsWith(SEALED_PREFIX)) return value;
  try {
    const raw = Buffer.from(value.slice(SEALED_PREFIX.length), 'base64url');
    const decipher = crypto.createDecipheriv('aes-256-gcm', tokenKey(), raw.subarray(0, 12));
    decipher.setAuthTag(raw.subarray(12, 28));
    return Buffer.concat([decipher.update(raw.subarray(28)), decipher.final()]).toString('utf8');
  } catch {
    return '';
  }
};

const SECRET_FIELDS = new Set(['password', 'PassWord', 'reset_otp', 'reset_otp_expiry']);
const TOKEN_FIELDS = new Set(['token', 'doctor_token', 'patient_token', 'callerToken', 'calleeToken']);

/** Removes passwords/OTPs and seals push tokens anywhere in a response body. */
exports.sanitizeResponse = function sanitize(value) {
  if (Array.isArray(value)) return value.map(sanitize);
  if (!value || typeof value !== 'object') return value;
  const out = {};
  for (const [k, v] of Object.entries(value)) {
    if (SECRET_FIELDS.has(k)) continue;
    out[k] = TOKEN_FIELDS.has(k) && typeof v === 'string' ? exports.sealToken(v) : sanitize(v);
  }
  return out;
};
