var mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
var Schema = mongoose.Schema;

const messageschema = new Schema({
    sequence_id: {
        type: String,
        lovercase: true,
        trim: true,
        required: true
    },
    title: {
        type: String,
    },
    message: {
        type: String,
    },
    token: {
        type: String
    },
    patient_id: {
        type: Schema.Types.ObjectId,
    },
    doctor_id: {
        type: Schema.Types.ObjectId,
    },
    status: {
        type: String,
        enum: ['sent', 'delivered', 'read'],
        default: 'sent'
    },
    create_date: {
        type: Date,
        default: Date.now
    }
});




messageschema.index({ create_date: 1 }, { background: true });

//Create a Schema method to compare password 

module.exports = mongoose.model('message', messageschema);