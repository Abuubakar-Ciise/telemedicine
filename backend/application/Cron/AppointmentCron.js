var Appointment = require("../model/appointment.js");
var Patient = require("../model/patient.js");
var Doctor = require("../model/doctor.js");
var Shifts = require("../model/shifts.js");
var cron = require("node-cron");
const { send_notification } = require("../controller/utils.js");
var moment = require("moment-timezone");
function scheduleAppointmentReminders() {
  cron.schedule("* * * * *", async () => {
    console.log("🚀 appointment reminder cron triggered");

    try {
      const now = moment().tz("Africa/Nairobi");  // Set to Africa/Nairobi time zone
      const fiveMinutesLater = moment().add(5, "minutes").tz("Africa/Nairobi");

      const appointments = await Appointment.find({
        reminderSent: { $ne: true },
        status: { $in: [1, 4] }
      });

      for (const appt of appointments) {
        console.log(`🔍 Checking appointment ${appt._id} for reminders`);
        const patient = await Patient.findById(appt.patient_id);
        const doctor = await Doctor.findById(appt.doctor_id);
        const shift = appt.shifts_id
          ? await Shifts.findById(appt.shifts_id)
          : null;

        if (!shift) continue;

        const today = moment().tz("Africa/Nairobi").format("dddd");  // Ensure today is in your local time zone
        if (shift.day !== today) continue;

        const shiftTimeMoment = moment.tz(shift.time, "hh:mm A", "Africa/Nairobi");  // Set shift time to local time zone
        console.log(
          `🔍 Shift time for ${shift.day} is ${shift.time} (${shiftTimeMoment.format("HH:mm")})`
        );

        const shiftToday = moment().tz("Africa/Nairobi").set({
          hour: shiftTimeMoment.get("hour"),
          minute: shiftTimeMoment.get("minute"),
          second: 0,
          millisecond: 0,
        });

        if (
          shiftToday.isSameOrAfter(now) &&
          shiftToday.isSameOrBefore(fiveMinutesLater)
        ) {
          console.log(
            `🔔 Sending reminder for appointment ${appt._id} at shift time ${shift.time}`
          );

          if (patient && patient.token) {
            send_notification(
              {
                token: patient.token,
                title: "Appointment Reminder",
                message: `You have an appointment on ${appt.appointment_date} with shift ${shift.day} at ${shift.time}. Please be ready.`,
                dataPayload: {
                  type: "appointment_reminder",
                  appointmentId: appt._id.toString(),
                },
              },
              (err, result) => {
                if (err) {
                  console.log("❌ patient notification error", err);
                } else {
                  console.log("✅ patient notification sent", result);
                }
              }
            );
          }

          if (doctor && doctor.token) {
            send_notification(
              {
                token: doctor.token,
                title: "Appointment Reminder",
                message: `You have an appointment with ${
                  patient ? patient.name : "a patient"
                } today (${shift.day}) at ${shift.time}.`,
                dataPayload: {
                  type: "appointment_reminder",
                  appointmentId: appt._id.toString(),
                },
              },
              (err, result) => {
                if (err) {
                  console.log("❌ doctor notification error", err);
                } else {
                  console.log("✅ doctor notification sent", result);
                }
              }
            );
          }

          appt.reminderSent = true;
          await appt.save();
        } else {
          console.log(
            `⏰ Shift ${shift.day} ${shift.time} is not within next 5 minutes — skipping.`
          );
        }
      }
    } catch (e) {
      console.error("❌ cron appointment error", e.message);
    }
  });
}

module.exports = {
  scheduleAppointmentReminders
};
