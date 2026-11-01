const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const labRequestSchema = new Schema({
    sequence_id: {
        type: String,
        required: true,
        trim: true,
        lowercase: true,
    },
    patient_id: {
        type: Schema.Types.ObjectId,
        ref: 'Patient',
        required: true,
    },
    doctor_id: {
        type: Schema.Types.ObjectId,
        ref: 'Doctor',
        required: true,
    },
    appointment_id: {
        type: Schema.Types.ObjectId,
        ref: 'Appointment',
    },
    requested_tests: [
        {
            test_name: {
                type: String,
                required: true,
                trim: true
            },
            description: String,
            priority: {
                type: String,
            }
        }
    ],
    status: {
        type: String,
    },
    notes: {
        type: String
    },
    lab_date: {
        type: Date
    },
    create_date: {
        type: Date,
        default: Date.now
    }
});

labRequestSchema.index({ create_date: 1 }, { background: true });

module.exports = mongoose.model('labRequest', labRequestSchema);
