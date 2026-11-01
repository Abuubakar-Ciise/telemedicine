var mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
var Schema = mongoose.Schema;

const userschema = new Schema({
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


userschema.index({ email: 1 }, { background: true });
userschema.index({ create_date: 1 }, { background: true });

//Create a Schema method to compare password 
userschema.methods.comparePassword = function (passwords) {
    return bcrypt.compareSync(passwords, this.password);
}
module.exports = mongoose.model('users', userschema);