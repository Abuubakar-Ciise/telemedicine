// Create a dashboard admin, or reset the password of an existing one.
//
//   npm run create-admin -- --name "Abuubakar" --phone 610000000 --email me@example.com --password Secret123
//
// If an admin with the same phone or email exists, its password is reset and it is re-enabled.
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const Utils = require('../application/controller/utils');
const { validatePassword } = require('../application/admin/helpers');

function arg(name) {
  const i = process.argv.indexOf(`--${name}`);
  return i > -1 ? process.argv[i + 1] : undefined;
}

(async () => {
  const name = arg('name');
  const phone = arg('phone');
  const email = arg('email');
  const password = arg('password');

  if (!password || (!phone && !email)) {
    console.log('Usage: npm run create-admin -- --name "Name" --phone 61xxxxxxx --email you@example.com --password Secret123');
    process.exit(1);
  }
  const problem = validatePassword(password);
  if (problem) {
    console.error(problem);
    process.exit(1);
  }

  await mongoose.connect(process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/telemedicine_db');
  const Admin = require('../application/model/admin');

  const or = [];
  if (phone) or.push({ phone });
  if (email) or.push({ email });
  let admin = await Admin.findOne({ $or: or });

  if (admin) {
    admin.password = bcrypt.hashSync(password, 10);
    admin.status = 1;
    if (name) admin.name = name;
    await admin.save();
    console.log(`Password reset for existing admin "${admin.name}" (${admin.phone})`);
  } else {
    if (!name || !phone) {
      console.error('--name and --phone are required to create a new admin');
      process.exit(1);
    }
    admin = await Admin.create({
      sequence_id: Utils.get_unique_id(),
      name, phone, email,
      password: bcrypt.hashSync(password, 10),
      status: 1,
      type: 0,
    });
    console.log(`Created admin "${admin.name}" (${admin.phone})`);
  }
  await mongoose.disconnect();
})().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
