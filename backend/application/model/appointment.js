var mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
var Schema = mongoose.Schema;

const appointmentschema = new Schema({
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
    appointment_date: {
        type: String, // Change from Date to String
        required: true
    }, 
    shifts_id: {
        type: Schema.Types.ObjectId,
    },  
    is_reviewed: {
        type: Boolean,
        default: false
    },
    status: {
        type: Number,
        default: 1,
    },
    token: {
        type: String,
    },
    reason: {
        type: String,
    },
    type: {
        type: Number,
        default: 0
    },
    create_date: {
        type: Date,
        default: Date.now
    },
    // Add this field to track if reminder was sent
    reminderSent: {
        type: Boolean,
        default: false
    }
});


// Middleware to format date before saving
appointmentschema.pre('save', function (next) {
    const options = { day: '2-digit', month: 'long', year: 'numeric' };
    this.appointment_date = new Intl.DateTimeFormat('en-GB', options).format(new Date(this.appointment_date));
    next();
});

appointmentschema.index({ create_date: 1 }, { background: true });


module.exports = mongoose.model('appointment', appointmentschema);