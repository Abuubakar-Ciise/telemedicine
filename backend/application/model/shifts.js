var mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
var Schema = mongoose.Schema;

const shiftsschema = new Schema({
    sequence_id: {
        type: String,
        lovercase: true,
        trim: true,
        required: true
    },

    doctor_id:{
        type:Schema.Types.ObjectId,
      },

    day: {
        type: String,
        enum: [
         "Saturday",
          "Sunday",
          "Monday",
          "Tuesday",
          "Wednesday",
          "Thursday",
          "Friday"
        ],
      },
    

      time: {
        type: String,
        match: /^(0?[1-9]|1[0-2]):([0-5]\d) (AM|PM)$/, // Format: HH:mm AM/PM
      },
      

      status: {
        type: Number,
        default: 0
    },
    extra_detail: {
      type: String,
  },

    create_date: {
        type: Date,
        default: Date.now
    },
});


module.exports = mongoose.model('shifts', shiftsschema);