var mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
var Schema = mongoose.Schema;

const hospitalschema = new Schema({
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
    phone: {
        type: String,
        unique: true,
        trim: true,
        required: true
    },

      address: {
        type: String,
        required: true,
        trim: true
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
    picture: String,
    create_date: {
        type: Date,
        default: Date.now
    }
});


hospitalschema.index({ email: 1 }, { background: true });
hospitalschema.index({ create_date: 1 }, { background: true });

//Create a Schema method to compare password 
hospitalschema.methods.comparePassword = function (passwords) {
    return bcrypt.compareSync(passwords, this.password);
}
module.exports = mongoose.model('hospital', hospitalschema);