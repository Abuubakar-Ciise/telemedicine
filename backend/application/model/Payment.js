var mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
var Schema = mongoose.Schema;

const paymentschema = new Schema({
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
    sender_phone: {
        type: String,
        trim: true,
        required: true
    },
    reciver_phone: {
        type: String,
        trim: true,
        required: true
    },
    amount:{
        type:Number
    },
    payment_method:{
        type:String,
        default:"EVC-Plus"
    },
    status: {
        type: Number,
        default: 0,
    },
    token: {
        type: String,
    },
    type: {
        type: Number,
        default: 0
    },
    create_date: {
        type: Date,
        default: Date.now
    }
});


paymentschema.index({ create_date: 1 }, { background: true });


module.exports = mongoose.model('payment', paymentschema);