// Admin dashboard resources: one entry per section of the dashboard.
//
//   model      Mongoose model name
//   lookups    related collections joined into list/detail results as "<as>_name"
//   search     fields matched by the ?search= query
//   filters    query params allowed as exact-match filters (ObjectId fields auto-cast)
//   fields     fields an admin may write on create/update
//   numbers    fields cast to Number
//   password   true -> accepts "password" (bcrypt-hashed; doctors/patients also get PassWord for the app login)
//   image      true -> accepts an uploaded "picture" file
//   readOnly   true -> no create/update from the dashboard
//   create/update false -> disable that action
//   label      field used for dropdown options
//   defaults   function returning extra values for new records
//   transform  function(data, { isCreate }) to normalise values before saving

const Utils = require('../controller/utils');
const { to12Hour, formatAppointmentDate } = require('./helpers');

const doctorLookup = { from: 'doctors', localField: 'doctor_id', as: 'doctor' };
const patientLookup = { from: 'patients', localField: 'patient_id', as: 'patient' };

module.exports = {
  doctors: {
    model: 'doctor',
    lookups: [
      { from: 'hospitals', localField: 'hospital_id', as: 'hospital' },
      { from: 'specialities', localField: 'speciality_id', as: 'speciality' },
    ],
    search: ['name', 'email', 'phone', 'user_name', 'sequence_id', 'hospital_name', 'speciality_name'],
    filters: ['status', 'hospital_id', 'speciality_id'],
    fields: ['name', 'email', 'user_name', 'phone', 'consultation_fee', 'experience_years', 'speciality_id',
      'hospital_id', 'countries', 'extra_detail', 'status', 'rating'],
    numbers: ['consultation_fee', 'experience_years', 'status', 'rating'],
    password: true,
    passwordForApp: true,
    image: true,
    label: 'name',
    defaults: () => ({ sequence_id: Utils.get_unique_id(), license_number: Utils.get_unique_id(), type: 0, status: 1, countries: 'Somalia' }),
  },

  patients: {
    model: 'patient',
    search: ['name', 'email', 'phone', 'user_name', 'sequence_id', 'address'],
    filters: ['status', 'gender'],
    fields: ['name', 'email', 'user_name', 'phone', 'age', 'address', 'gender', 'extra_detail', 'status'],
    numbers: ['age', 'status'],
    password: true,
    passwordForApp: true,
    image: true,
    label: 'name',
    defaults: () => ({ sequence_id: Utils.get_unique_id(), type: 0, status: 1 }),
  },

  hospitals: {
    model: 'hospital',
    search: ['name', 'email', 'phone', 'address', 'sequence_id'],
    filters: ['type'],
    fields: ['name', 'email', 'phone', 'address', 'extra_detail', 'type'],
    numbers: ['type'],
    image: true,
    label: 'name',
    defaults: () => ({ sequence_id: Utils.get_unique_id(), type: 0 }),
  },

  specialities: {
    model: 'speciality',
    search: ['name', 'sequence_id', 'extra_detail'],
    filters: ['status'],
    fields: ['name', 'extra_detail', 'status'],
    numbers: ['status'],
    image: true,
    label: 'name',
    defaults: () => ({ sequence_id: Utils.get_unique_id(), status: 1 }),
  },

  appointments: {
    model: 'appointment',
    lookups: [doctorLookup, patientLookup, { from: 'shifts', localField: 'shifts_id', as: 'shift', nameField: 'time' }],
    extraProject: { shift_day: '$shift.day' },
    search: ['sequence_id', 'doctor_name', 'patient_name', 'appointment_date', 'reason'],
    filters: ['status', 'doctor_id', 'patient_id'],
    fields: ['doctor_id', 'patient_id', 'shifts_id', 'appointment_date', 'status', 'reason', 'type', 'is_reviewed'],
    numbers: ['status', 'type'],
    label: 'sequence_id',
    defaults: () => ({ sequence_id: Utils.get_unique_id(), status: 1, type: 0 }),
    transform: (data) => {
      if (data.appointment_date) data.appointment_date = formatAppointmentDate(data.appointment_date);
    },
  },

  payments: {
    model: 'payment',
    lookups: [doctorLookup, patientLookup],
    search: ['sequence_id', 'doctor_name', 'patient_name', 'sender_phone', 'reciver_phone', 'payment_method'],
    filters: ['status', 'doctor_id', 'patient_id', 'payment_method'],
    fields: ['doctor_id', 'patient_id', 'sender_phone', 'reciver_phone', 'amount', 'payment_method', 'status', 'type'],
    numbers: ['amount', 'status', 'type'],
    label: 'sequence_id',
    defaults: () => ({ sequence_id: Utils.get_unique_id(), status: 1, type: 0 }),
  },

  shifts: {
    model: 'shifts',
    lookups: [doctorLookup],
    search: ['sequence_id', 'doctor_name', 'day', 'time'],
    filters: ['status', 'doctor_id', 'day'],
    fields: ['doctor_id', 'day', 'time', 'status', 'extra_detail'],
    numbers: ['status'],
    label: 'time',
    defaults: () => ({ sequence_id: Utils.get_unique_id(), status: 1 }),
    transform: (data) => {
      if (data.time) data.time = to12Hour(data.time);
    },
    // Creating accepts { doctor_id, days: [...], time } and makes one shift per day.
    multiCreate: 'days',
  },

  prescriptions: {
    model: 'Prescription',
    lookups: [doctorLookup, patientLookup],
    search: ['sequence_id', 'doctor_name', 'patient_name', 'extra_detail', 'medicines.medicine_name'],
    filters: ['doctor_id', 'patient_id'],
    readOnly: true,
  },

  labs: {
    model: 'labs',
    lookups: [doctorLookup, patientLookup],
    search: ['sequence_id', 'doctor_name', 'patient_name'],
    filters: ['doctor_id', 'patient_id'],
    readOnly: true,
  },

  'lab-requests': {
    model: 'labRequest',
    lookups: [doctorLookup, patientLookup],
    search: ['sequence_id', 'doctor_name', 'patient_name', 'status', 'notes', 'requested_tests.test_name'],
    filters: ['status', 'doctor_id', 'patient_id'],
    fields: ['status', 'notes'],
    create: false,
  },

  consultations: {
    model: 'conseltation',
    lookups: [doctorLookup, patientLookup],
    search: ['sequence_id', 'doctor_name', 'patient_name', 'roomID', 'status'],
    filters: ['status', 'doctor_id', 'patient_id'],
    readOnly: true,
  },

  feedback: {
    model: 'feedback',
    lookups: [doctorLookup, patientLookup],
    search: ['sequence_id', 'doctor_name', 'patient_name', 'comments'],
    filters: ['rating', 'doctor_id', 'patient_id'],
    numbers: ['rating'],
    readOnly: true,
  },

  messages: {
    model: 'message',
    lookups: [doctorLookup, patientLookup],
    search: ['sequence_id', 'title', 'message', 'doctor_name', 'patient_name'],
    filters: ['status', 'doctor_id', 'patient_id'],
    readOnly: true, // created through POST /admin/api/messages/send
  },

  ads: {
    model: 'adds',
    search: ['sequence_id', 'extra_detail'],
    filters: ['status'],
    fields: ['extra_detail', 'status'],
    numbers: ['status'],
    image: true,
    defaults: () => ({ sequence_id: Utils.get_unique_id(), status: 1 }),
  },

  'self-management': {
    model: 'selfmanagment',
    search: ['sequence_id', 'title', 'extra_detail'],
    filters: ['status'],
    fields: ['title', 'extra_detail', 'status'],
    numbers: ['status'],
    image: true,
    label: 'title',
    defaults: () => ({ sequence_id: Utils.get_unique_id(), status: 1 }),
  },

  admins: {
    model: 'admin',
    search: ['name', 'email', 'phone', 'user_name', 'sequence_id'],
    filters: ['status', 'type'],
    fields: ['name', 'email', 'user_name', 'phone', 'status', 'type', 'extra_detail'],
    numbers: ['status', 'type'],
    password: true,
    image: true,
    label: 'name',
    defaults: () => ({ sequence_id: Utils.get_unique_id(), status: 1, type: 0 }),
  },
};
