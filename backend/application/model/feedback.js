var mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
var Schema = mongoose.Schema;

const feedbackschema = new Schema({
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
    appointment_id: {
        type: Schema.Types.ObjectId,
    },
    rating: {
        type: Number,
        required: true,
        min: 1,
        max: 5
     },
    comments: {
         type: String 
      },
    create_date: {
        type: Date,
        default: Date.now
    }
});


feedbackschema.index({ create_date: 1 }, { background: true });


module.exports = mongoose.model('feedback', feedbackschema);