const mongoose = require('mongoose');

module.exports = function () {
  const DB_URL = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/telemedicine_db';

  mongoose.set('strictQuery', true);
  mongoose
    .connect(DB_URL)
    .then(() => console.log('MongoDB connected'))
    .catch((err) => {
      console.error('MongoDB connection error:', err.message);
      process.exit(1);
    });

  require('../application/model/admin');
  require('../application/model/users');
  require('../application/model/doctor');
  require('../application/model/patient');
  require('../application/model/appointment');
  require('../application/model/hospital');
  require('../application/model/Payment');
  require('../application/model/message');
  require('../application/model/feedback');
  require('../application/model/shifts');
  require('../application/model/adds');
  require('../application/model/selfmanagment');
  require('../application/model/conseltation');
  require('../application/model/speciality');
  require('../application/model/prescription');
  require('../application/model/labs');
  require('../application/model/LabRequest');

  return mongoose.connection;
};
