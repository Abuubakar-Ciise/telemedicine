var mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
var Schema = mongoose.Schema;

const conseltationschema = new Schema({
    sequence_id: {
        type: String,
        lovercase: true,
        trim: true,
        required: true
    },
    doctor_id: {
        type: Schema.Types.ObjectId,
    },
    patient_id: {
        type: Schema.Types.ObjectId,
    },
    roomID: {
        type: String,
        required: true
      },
      status: {
        type: String,
        enum: ["ringing", "answered", "ended", "pending", "declined", "cancelled", "missed"],
        default: "pending"
      },
    call_type: {
        type: String, // '0' voice, '1' video
    },
    caller_type: {
        type: String, // 'doctor' or 'patient'
    },
    update_date: {
        type: Date,
    },
    create_date: {
        type: Date,
        default: Date.now
    }
});

conseltationschema.index({ create_date: 1 }, { background: true });


module.exports = mongoose.model('conseltation', conseltationschema);