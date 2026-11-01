// Creates the main dashboard admin account.
//
//   npm run seed:admins            create the admin (left untouched if it already exists)
//   npm run seed:admins -- --reset also reset its password to the default below
//
// Change the password after first login (My profile > Change password).
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const Utils = require('../application/controller/utils');

// Values come from backend/.env (never committed). See .env.example.
const MAIN_ADMIN = {
  name: process.env.SEED_ADMIN_NAME || 'Admin',
  email: process.env.SEED_ADMIN_EMAIL,
  phone: process.env.SEED_ADMIN_PHONE,
  user_name: process.env.SEED_ADMIN_USERNAME || 'admin',
  password: process.env.SEED_ADMIN_PASSWORD,
};

(async () => {
  if (!MAIN_ADMIN.email || !MAIN_ADMIN.phone || !MAIN_ADMIN.password) {
    console.error('Set SEED_ADMIN_EMAIL, SEED_ADMIN_PHONE and SEED_ADMIN_PASSWORD in backend/.env first.');
    process.exit(1);
  }
  const reset = process.argv.includes('--reset');
  await mongoose.connect(process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/telemedicine_db');
  const Admin = require('../application/model/admin');

  const a = MAIN_ADMIN;
  let admin = await Admin.findOne({ $or: [{ email: a.email }, { phone: a.phone }] });
  let action;
  if (!admin) {
    admin = await Admin.create({
      sequence_id: Utils.get_unique_id(),
      name: a.name,
      email: a.email,
      phone: a.phone,
      user_name: a.user_name,
      password: bcrypt.hashSync(a.password, 10),
      status: 1,
      type: 0,
    });
    action = 'created';
  } else if (reset) {
    admin.password = bcrypt.hashSync(a.password, 10);
    admin.status = 1;
    await admin.save();
    action = 'password reset';
  } else {
    action = 'already exists (unchanged)';
  }

  console.table([{
    name: a.name,
    email: a.email,
    username: a.user_name,
    phone: a.phone,
    password: action === 'already exists (unchanged)' ? '(unchanged)' : a.password,
    action,
  }]);
  console.log('Log in to the dashboard with the email, username or phone above.');
  await mongoose.disconnect();
})().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
