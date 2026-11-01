var mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
var Schema = mongoose.Schema;

const specialityschema = new Schema({
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
    status: {
        type: Number,
        default: 0
    },
    extra_detail: {
        type: String,
    },
    picture: String,
    create_date: {
        type: Date,
        default: Date.now
    },
});



specialityschema.index({ create_date: 1 }, { background: true });

module.exports = mongoose.model('speciality', specialityschema);