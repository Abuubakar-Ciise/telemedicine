var mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
var Schema = mongoose.Schema;

const doctorschema = new Schema({
  sequence_id: {
    type: String,
    lovercase: true,
    trim: true,
    required: true
  },
  name: {
    type: String,
    required: true
  },
  email: {
    type: String,
  },
  user_name: {
    type: String,
  },
  phone: {
    type: String,
    unique: true,
    trim: true,
    required: true
  },
  password: String,
  PassWord: String,
  status: {
    type: Number,
    default: 0
  },
  consultation_fee: {
    type: Number,
    required: true,
  },
  license_number: {
    type: String,
    lovercase: true,
    trim: true,
    required: true
  },
  experience_years: {
    type: Number,
    required: true,
    min: 0,
  },
  speciality_id: {
    type: Schema.Types.ObjectId
  },
  countries: {
    type: String,
    required: true,
  },
  hospital_id: {
    type: Schema.Types.ObjectId,
  },
  rating: {
    type: Number,
    min: 0,
    max: 5,
    default: 0,
  },
  token: {
    type: String,
  },
  extra_detail: {
    type: String,
  },
  reset_otp: {
    type: Number,
  },
  reset_otp_expiry: {
    type: Date,
  },
  type: {
    type: Number,
    default: 0
  },
  picture: String,
  create_date: {
    type: Date,
    default: Date.now
  },
});


doctorschema.index({ email: 1 }, { background: true });
doctorschema.index({ create_date: 1 }, { background: true });

//Create a Schema method to compare password 
doctorschema.methods.comparePassword = function (passwords) {
  return bcrypt.compareSync(passwords, this.password);
}
module.exports = mongoose.model('doctor', doctorschema);