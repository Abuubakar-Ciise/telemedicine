var mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
var Schema = mongoose.Schema;

const adminschema = new Schema({   //Schema define stracute that will be store database
    sequence_id: {
        type: String,
        unique: true,
        lovercase: true,
        trim: true,
        required: true
    },
    name: {
        type: String,
        required: true
    },
    email: {
        type: String,
    },
    user_name: {
        type: String,
    },
    phone: {
        type: String,
        unique: true,
        trim: true,
        required: true
    },
    password: String,
    status: {
        type: Number,
        default: 0
    },
    token: {
        type: String,
    },
    last_login: {
        type: Date,
        default: null
    },
    extra_detail: {
        type: String,
    },
    type: {
        type: Number,
        default: 0
    },
    allowed_urls: { type: Array, default: [] },
    picture: String,
    create_date: {
        type: Date,
        default: Date.now
    }
});


adminschema.index({ email: 1 }, { background: true });
adminschema.index({ create_date: 1 }, { background: true });

//Create a Schema method to compare password 
adminschema.methods.comparePassword = function (passwords) {
    return bcrypt.compareSync(passwords, this.password);
}
module.exports = mongoose.model('admin', adminschema);