const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const labsSchema = new Schema({
    sequence_id: {
        type: String,
        lowercase: true,
        trim: true,
        required: true
    },
    patient_id: {
        type: Schema.Types.ObjectId,
        required: true
    },
    doctor_id: {
        type: Schema.Types.ObjectId,
        required: true
    },
    appointment_id: {
        type: Schema.Types.ObjectId,
    },

    lab_date: {
        type: Date,
        default: Date.now
        
    },
    report_url: {
        type: String
    },
    create_date: {
        type: Date,
        default: Date.now
    }
});

labsSchema.index({ create_date: 1 }, { background: true });

module.exports = mongoose.model('labs', labsSchema);  