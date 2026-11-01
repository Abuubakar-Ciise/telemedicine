var mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
var Schema = mongoose.Schema;

const patientschema = new Schema({
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
    PassWord:String,
    status: {
        type: Number,
        default: 0
    },
    age: {
        type: Number,
        min: 0
      },
      address: {
        type: String,
        required: true,
        trim: true
      },
      gender: {
        type: String,
      },
    token: {
        type: String,
    },
    extra_detail: {
        type: String,
    },
    type: {
        type: Number,
        default: 0
    },
    reset_otp: {
        type: Number,
    },
    reset_otp_expiry: {
        type: Date,
    },
    picture: String,
    create_date: {
        type: Date,
        default: Date.now
    }
});


patientschema.index({ email: 1 }, { background: true });
patientschema.index({ create_date: 1 }, { background: true });

//Create a Schema method to compare password 
patientschema.methods.comparePassword = function (passwords) {
    return bcrypt.compareSync(passwords, this.password);
}
module.exports = mongoose.model('patient', patientschema);