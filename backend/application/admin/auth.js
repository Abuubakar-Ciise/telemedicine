// Admin dashboard authentication (JWT).
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { saveUpload, validatePassword } = require('./helpers');

const Admin = mongoose.model('admin');

function secret() {
  const value = process.env.ADMIN_JWT_SECRET;
  if (!value) throw new Error('ADMIN_JWT_SECRET is not set in .env');
  return value;
}

function publicAdmin(admin) {
  const a = admin.toObject ? admin.toObject() : admin;
  delete a.password;
  delete a.token;
  delete a.__v;
  return a;
}

// Middleware: requires a valid "Authorization: Bearer <token>" header.
exports.requireAdmin = async function (req, res, next) {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) return res.status(401).send({ success: false, message: 'Not logged in' });

    const payload = jwt.verify(token, secret());
    const admin = await Admin.findById(payload.id);
    if (!admin || admin.status !== 1) {
      return res.status(401).send({ success: false, message: 'Account not found or disabled' });
    }
    req.admin = admin;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError' || err.name === 'JsonWebTokenError') {
      return res.status(401).send({ success: false, message: 'Session expired, please log in again' });
    }
    next(err);
  }
};

// POST /admin/api/auth/login  { login, password }  (login = email, phone or username)
exports.login = async function (req, res, next) {
  try {
    const login = String(req.body.login || '').trim();
    const password = String(req.body.password || '');
    if (!login || !password) {
      return res.status(400).send({ success: false, message: 'Email/phone and password are required' });
    }

    const admin = await Admin.findOne({
      $or: [{ email: login.toLowerCase() }, { email: login }, { phone: login }, { user_name: login }],
    });
    if (!admin || !admin.password || !bcrypt.compareSync(password, admin.password)) {
      return res.status(401).send({ success: false, message: 'Invalid login or password' });
    }
    if (admin.status !== 1) {
      return res.status(403).send({ success: false, message: 'This account is disabled' });
    }

    admin.last_login = new Date();
    await admin.save();

    const token = jwt.sign({ id: admin._id.toString() }, secret(), {
      expiresIn: process.env.ADMIN_JWT_EXPIRES_IN || '12h',
    });
    res.send({ success: true, token, admin: publicAdmin(admin) });
  } catch (err) {
    next(err);
  }
};

// GET /admin/api/auth/me
exports.me = function (req, res) {
  res.send({ success: true, admin: publicAdmin(req.admin) });
};

// PUT /admin/api/auth/me  (update own profile)
exports.updateMe = async function (req, res, next) {
  try {
    const admin = req.admin;
    for (const key of ['name', 'email', 'user_name', 'phone']) {
      if (req.body[key] !== undefined) admin[key] = req.body[key];
    }
    const picture = saveUpload(req, 'picture');
    if (picture) admin.picture = picture;
    await admin.save();
    res.send({ success: true, admin: publicAdmin(admin) });
  } catch (err) {
    next(err);
  }
};

// POST /admin/api/auth/change-password  { current_password, new_password }
exports.changePassword = async function (req, res, next) {
  try {
    const { current_password, new_password } = req.body;
    if (!bcrypt.compareSync(String(current_password || ''), req.admin.password || '')) {
      return res.status(400).send({ success: false, message: 'Current password is wrong' });
    }
    const problem = validatePassword(new_password);
    if (problem) return res.status(400).send({ success: false, message: problem });

    req.admin.password = bcrypt.hashSync(String(new_password), 10);
    await req.admin.save();
    res.send({ success: true, message: 'Password changed' });
  } catch (err) {
    next(err);
  }
};
