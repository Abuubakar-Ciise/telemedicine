var mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
var Schema = mongoose.Schema;

const selfmanagmentschema = new Schema({
    sequence_id: {
        type: String,
        lovercase: true,
        trim: true,
        required: true
    },
    status: {
        type: Number,
        default: 0
    },

    title:{
        type:String,
        require:true
    },
    extra_detail: {
        require:true,
        type: String,
    },
    picture: String,
    create_date: {
        type: Date,
        default: Date.now
    },
});



selfmanagmentschema.index({ create_date: 1 }, { background: true });

module.exports = mongoose.model('selfmanagment', selfmanagmentschema);