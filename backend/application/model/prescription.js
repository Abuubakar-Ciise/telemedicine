const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const prescriptionSchema = new Schema({
    sequence_id: {
        type: String,
        lowercase: true,
        trim: true,
        required: true
    },
    medicines: [{
        duration: {
            type: Number,
            default: 0
        },
        medicine_name: {
            type: String,
            required: true
        },
        dosage: {
            type: Number,
            required: true
        },
        frequency:{
            type:String,
            required:true
        }
    }],

    doctor_id: {
        type: Schema.Types.ObjectId
    },
    patient_id: {
        type: Schema.Types.ObjectId
    },
    appointment_id: {
        type: Schema.Types.ObjectId,
    },
    extra_detail: {
        type: String,
    },
    picture: {
        type: String
    },
    create_date: {
        type: Date,
        default: Date.now
    }
});

prescriptionSchema.index({ create_date: 1 }, { background: true });

module.exports = mongoose.model('Prescription', prescriptionSchema);




