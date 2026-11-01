require('dotenv').config();
process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const connectDB = require('./config/mongoose');
const createApp = require('./config/express');
const { scheduleAppointmentReminders } = require('./application/Cron/AppointmentCron.js');

const fs = require('fs');
for (const dir of ['uploads/admin_profile', 'uploads/lab_reports']) fs.mkdirSync(dir, { recursive: true });

const port = process.env.PORT || 2003;

connectDB();
const app = createApp();
scheduleAppointmentReminders();

app.listen(port, () => console.log('API server running on port ' + port));

module.exports = app;
