// Helpers shared by the admin API.
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
const Utils = require('../controller/utils');

const UPLOAD_ROOT = path.join(__dirname, '..', '..', 'uploads');

/**
 * Move an uploaded file (multer temp file) into uploads/<folder>/ and return the
 * stored path (e.g. "admin_profile/abc.jpg"), the same format the mobile app uses.
 */
exports.saveUpload = function (req, fieldName, folder = 'admin_profile') {
  const file = (req.files || []).find((f) => f.fieldname === fieldName);
  if (!file) return null;

  const ext = (path.extname(file.originalname || '') || '.jpg').toLowerCase();
  const fileName = Utils.tokenGenerator(29) + ext;
  const dir = path.join(UPLOAD_ROOT, folder);
  fs.mkdirSync(dir, { recursive: true });
  fs.copyFileSync(file.path, path.join(dir, fileName));
  fs.unlink(file.path, () => {});
  return `${folder}/${fileName}`;
};

exports.deleteUpload = function (storedPath) {
  if (!storedPath || typeof storedPath !== 'string' || storedPath.includes('..')) return;
  fs.unlink(path.join(UPLOAD_ROOT, storedPath), () => {});
};

// Same rule the old admin panel used: 8-30 chars, letters and digits, no spaces.
exports.validatePassword = function (password) {
  const p = String(password || '');
  if (p.length < 8 || p.length > 30) return 'Password must be 8-30 characters';
  if (!/[a-z]/i.test(p) || !/\d/.test(p)) return 'Password must contain letters and numbers';
  if (/\s/.test(p)) return 'Password must not contain spaces';
  return null;
};

exports.isObjectId = (v) => typeof v === 'string' && mongoose.Types.ObjectId.isValid(v) && /^[a-f0-9]{24}$/i.test(v);
exports.toObjectId = (v) => new mongoose.Types.ObjectId(v);

// "14:30" -> "02:30 PM"; already formatted values are returned as-is.
exports.to12Hour = function (time) {
  if (!time) return time;
  const t = String(time).trim();
  if (/^(0?[1-9]|1[0-2]):[0-5]\d (AM|PM)$/i.test(t)) return t.toUpperCase();
  const m = t.match(/^(\d{1,2}):(\d{2})/);
  if (!m) return t;
  let h = Number(m[1]);
  const period = h >= 12 ? 'PM' : 'AM';
  h = h % 12 || 12;
  return `${String(h).padStart(2, '0')}:${m[2]} ${period}`;
};

// Same format the appointment model's pre-save hook produces: "05 September 2025"
exports.formatAppointmentDate = function (value) {
  if (!value) return value;
  const d = new Date(value);
  if (isNaN(d)) return value;
  return new Intl.DateTimeFormat('en-GB', { day: '2-digit', month: 'long', year: 'numeric' }).format(d);
};

exports.escapeRegex = (s) => String(s).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
