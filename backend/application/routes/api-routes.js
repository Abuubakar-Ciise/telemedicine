// Mobile app API routes (doctor & patient).
const api = require('../controllers/api-controller');

module.exports = function (app) {
  app.get('/health', (req, res) => res.send({ success: true, status: 'ok' }));

  app.route('/login_DoctorAndPatient').post(api.login_DoctorAndPatient);
  app.route('/register_Patient').post(api.register_Patient)
  app.route('/register_Doctor').post(api.register_Doctor)
  app.route('/getAll_Doctors').post(api.getAll_Doctors);
  app.route('/patient_appointements').post(api.patient_appointements); // waa all appointments uu patients uu qabsaday
  app.route('/doctor_appointements').post(api.doctor_appointements); // waa all appointments uu doctor uu laga qabsaday
  app.route('/patient_transection').post(api.patient_transection);  // waa all transecton ka uu bixiyey patient
  app.route('/doctor_transection').post(api.doctor_transection);  // waa all transecton ka uu qatay doctor ka
  app.route('/booking_Appointement').post(api.booking_Appointement);  //not work
  app.route('/payPayement').post(api.payPayement);   // not work
  app.route('/bookAndPay').post(api.bookAndPay);
  app.route('/getAll_Hospitals').post(api.getAll_Hospitals);
  app.route('/shifts').post(api.shifts);  // not work 
  app.route('/check_shifts').post(api.check_shifts);  // not work
  app.route('/Saturday_Shifts').post(api.Saturday_Shifts);
  app.route('/Sunday_Shifts').post(api.Sunday_Shifts);
  app.route('/Monday_Shifts').post(api.Monday_Shifts);
  app.route('/Tuesday_Shifts').post(api.Tuesday_Shifts);
  app.route('/Wednesday_Shifts').post(api.Wednesday_Shifts);
  app.route('/Thursday_Shifts').post(api.Thursday_Shifts);
  app.route('/Friday_Shifts').post(api.Friday_Shifts);
  app.route('/adds').post(api.adds);
  app.route('/selfmanagment').post(api.selfmanagment);
  app.route('/updateProfile').post(api.updateProfile);
  app.route('/docAndpat').post(api.docAndpat);
  app.route('/conseltaion').post(api.conseltaion);
  app.route('/save_conseltaion').post(api.save_conseltaion);  // not work
  app.route('/update_conseltaion').post(api.update_conseltaion);  // not work
  app.route('/update_token').post(api.update_token);
  app.route('/re_appointment').post(api.re_appointment)
  app.route('/feedbackPatient').post(api.feedbackPatient)
  app.route('/filter_Hospital').post(api.filter_Hospital)
  app.route('/filter_Speciality').post(api.filter_Speciality)
  app.route('/getAll_Speciality').post(api.getAll_Speciality);
  app.route("/save_prescription").post(api.save_prescription);
  app.route('/patient_prescriptions').post(api.patient_prescription); // waa all appointments uu patients uu qabsaday
  app.route('/doctor_prescriptions').post(api.doctor_prescriptions);
  app.route('/save_labs_record').post(api.save_labs_record);
  app.route('/patient_labs').post(api.patient_labs);
  app.route('/doctor_labs').post(api.doctor_labs);
  app.route('/changesPassword').post(api.changesPassword);
  app.route('/save_LabRequest').post(api.save_LabRequest)
  app.route('/doctor_LabRequest').post(api.doctor_LabRequest)
  app.route('/patient_LabRequest').post(api.patient_LabRequest)
  app.route('/forget_Password').post(api.forget_Password)
  app.route('/VerifyOtp').post(api.VerifyOtp)
  app.route('/resetPassword').post(api.resetPassword)
  app.route('/patient_notification').post(api.patient_notification)
  app.route('/doctor_notification').post(api.doctor_notification)
  app.route('/save_message').post(api.save_message)
  app.route('/allAppointments').post(api.allAppointments)
  app.route('/send_push').post(api.send_push);
  app.route('/call_start').post(api.call_start);
  app.route('/call_update').post(api.call_update);
  app.route('/call_status').post(api.call_status);
  app.route('/call_incoming').post(api.call_incoming);
};
