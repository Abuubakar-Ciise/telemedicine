// Mobile app API controller (doctor & patient endpoints).
const mongoose = require('mongoose');
const fs = require('fs');
const bcrypt = require('bcryptjs');
const Bcrypt = bcrypt;
const Utils = require('../controller/utils');

const Doctor = mongoose.model('doctor');
const Patient = mongoose.model('patient');
const Appointment = mongoose.model('appointment');
const Hospital = mongoose.model('hospital');
const Payment = mongoose.model('payment');
const Message = mongoose.model('message');
const Feedback = mongoose.model('feedback');
const Shifts = mongoose.model('shifts');
const Adds = mongoose.model('adds');
const SelfManagment = mongoose.model('selfmanagment');
const Conseltaion = mongoose.model('conseltation');
const Speciality = mongoose.model('speciality');
const Prescription = mongoose.model('Prescription');
const Labs = mongoose.model('labs');
const labRequest = mongoose.model('labRequest');

// Kept as a function so existing ObjectId(id) calls keep working on Mongoose 8.
const ObjectId = (id) => new mongoose.Types.ObjectId(id);

// Login for doctors and patients with email, phone or username.
exports.login_DoctorAndPatient = async function (req, res) {
    try {
        const login = String(req.body.email || req.body.login || '').trim();
        const password = String(req.body.PassWord || req.body.password || '');
        if (!login || !password) {
            return res.send({ success: false, message: 'Please enter your email/phone and password' });
        }
        const escaped = login.replace(/[.*+?^${}()|[\]\\]/g, (ch) => '\\' + ch);
        const rx = new RegExp('^' + escaped + '$', 'i');
        // Phones are saved in different formats (the app adds +252 for patients),
        // so match 610736551, +252610736551, 252610736551 and 0610736551 alike.
        const phones = [login];
        const local = login.replace(/\D/g, '').replace(/^252/, '').replace(/^0/, '');
        if (/^\d{7,12}$/.test(local)) phones.push(local, '+252' + local, '252' + local, '0' + local);
        const query = { $or: [{ email: rx }, { phone: { $in: phones } }, { user_name: rx }] };

        const passwordMatches = (user) =>
            (user.PassWord && user.PassWord === password) ||
            (user.password && Bcrypt.compareSync(password, user.password));

        for (const [Model, label] of [[Doctor, 'Doctor'], [Patient, 'Patient']]) {
            const users = await Model.find(query);
            const user = users.find(passwordMatches);
            if (user) {
                const updated = await Model.findByIdAndUpdate(user._id, { $set: { token: req.body.token || '' } }, { new: true });
                return res.send({ success: true, message: 'Successfully logged in as ' + label, record: updated });
            }
        }
        res.send({ success: false, message: 'Invalid email/phone or password' });
    } catch (err) {
        console.error('login_DoctorAndPatient:', err);
        res.status(500).send({ success: false, message: 'Server error while logging in' });
    }
}
exports.register_Patient = function (req, res) {
        console.log("body", req.body)
            Patient.findOne({ "phone": req.body.phone }).then((patient) => {
                console.log("user", patient)
                if (patient) {
                    res.send({
                        success:false,
                        message:"Sorry, There is an patient with this phone, please check the phone",
                    })
                } else {
                        var profile_file = req.files;
                        var name = req.body.name
                        var patient = new Patient({
                            name: name,
                            sequence_id: Utils.get_unique_id(),
                            email: req.body.email,
                            address:req.body.address,
                            gender:req.body.gender,
                            age:req.body.age,
                            phone: req.body.phone,
                            status: 1,
                            type:1,
                            extra_detail: req.body.extra_detail,
                            picture: "",
                            user_name: req.body.user_name,
                            PassWord: req.body.PassWord,
                            password: Bcrypt.hashSync(req.body.PassWord, 10)
                        });
                        if (profile_file != undefined && profile_file.length > 0) {
                            image_name = Utils.tokenGenerator(29) + '.jpg';
                            url = "./uploads/admin_profile/" + image_name;
                            liner = "admin_profile/" + image_name;

                            fs.readFile(req.files[0].path, function (err, data) {
                                fs.writeFile(url, data, 'binary', function (err) { });
                                fs.unlink(req.files[0].path, function (err, file) {

                                });
                            });

                            patient.picture = liner;
                        }
                        patient.save().then((patient) => {

                            res.send({
                                success:true,
                                message:"patient was created successfully",
                                record:patient
                            })
                        }).catch((err) => {
                            console.error('register_Patient:', err.message);
                            res.status(400).send({
                                success:false,
                                message: err.name === 'ValidationError'
                                    ? Object.values(err.errors).map((e) => e.message).join(', ')
                                    : 'Could not create the account: ' + err.message,
                            })
                        });
                }
            })

};



exports.register_Doctor = function(req, res){
    console.log("body", req.body)

    Doctor.findOne({ "phone": req.body.phone }).then((doctor) => {
        console.log("user", doctor)
        if (doctor) {
            res.send({
                success:false,
                message:"Sorry, There is an doctor with this phone, please check the phone",
            })
        }

        else {
            var profile_file = req.files;
            var name = req.body.name
            var doctor = new Doctor({
                name: name,
                sequence_id: Utils.get_unique_id(),
                email: req.body.email,
                license_number:Utils.get_unique_id(),
                phone: req.body.phone,
                status: 0,
                type:0,
                consultation_fee: req.body.consultation_fee,
                experience_years: req.body.experience_years,
                speciality_id: req.body.speciality_id,
                countries: req.body.countries,
                hospital_id: req.body.hospital_id,
                extra_detail: req.body.extra_detail,
                picture: "",
                user_name: req.body.user_name,
                PassWord: req.body.PassWord,
                password: Bcrypt.hashSync(req.body.PassWord, 10)
            });
            if (profile_file != undefined && profile_file.length > 0) {
                image_name = Utils.tokenGenerator(29) + '.jpg';
                url = "./uploads/admin_profile/" + image_name;
                liner = "admin_profile/" + image_name;

                fs.readFile(req.files[0].path, function (err, data) {
                    fs.writeFile(url, data, 'binary', function (err) { });
                    fs.unlink(req.files[0].path, function (err, file) {

                    });
                });

                doctor.picture = liner;
            }
            doctor.save().then((doctor) => {

                res.send({
                    success:true,
                    message:"doctor was created successfully",
                    record:doctor
                })
            });
    }

    })
    
}



// //Api get all doctors information
exports.getAll_Doctors = async function(req, res) {
    try {
        let doctors = await Doctor.aggregate([
            {
                $lookup: {
                    from: "hospitals",
                    localField: "hospital_id",
                    foreignField: "_id",
                    as: "data"
                }
            },
            { $unwind: "$data" },

            { $lookup:{
                from:"specialities",
                localField:"speciality_id",
                foreignField:"_id",
                as:"speciality_data"
                }},

                {$unwind:"$speciality_data"},
            {
                $project: {
                    _id: 1,
                    sequence_id: 1,
                    name: 1,
                    picture: 1,
                    phone: 1,
                    email: 1,
                    token:1,
                    hospital_name: "$data.name",
                    countries: 1,
                    speciality:"$speciality_data.name",
                    experience_years: 1,
                    consultation_fee: 1,
                    rating:1,
                    status: 1,
                    create_date: 1
                }
            }
        ]);

        if (doctors.length > 0) {
            // Loop through each doctor and update their rating
            for (let doctor of doctors) {
                let feedbacks = await Feedback.find({ doctor_id: doctor._id });
                // Calculate average rating
                let totalRating = feedbacks.reduce((sum, feedback) => sum + feedback.rating, 0);
                let averageRating = feedbacks.length > 0 ? totalRating / feedbacks.length : 0;
                // Update doctor's rating
                await Doctor.updateOne({ _id: doctor._id }, { $set: { rating: averageRating } });
                // // Add rating to response data
                // doctor.rating = averageRating;
                // Ensure only 1 decimal place
                doctor.rating = parseFloat(averageRating.toFixed(1));

            }

            res.send({
                success: true,
                message: "Successfully fetched all doctors",
                record: doctors
            });
        } else {
            res.send({
                success: false,
                message: "No doctors found"
            });
        }
    } catch (error) {
        console.error("Error in fetching doctors:", error);
        res.status(500).send({ success: false, message: "Server error" });
    }
};



 

//Api get all appointments patient
exports.patient_appointements = function(req, res){
        Appointment.aggregate([

            {
                $match: {
                    "patient_id": ObjectId(req.body.patient_id)
                }
            },

            {$lookup:{
                
                from:"doctors",
                localField:"doctor_id",
                foreignField:"_id",
                as:"doctor_data"
            
                }},
                
                {$unwind:"$doctor_data"},
                
                {$lookup:{
                
                from:"patients",
                localField:"patient_id",
                foreignField:"_id",
                as:"patient_data"
            
                }},
                
                {$unwind:"$patient_data"},

                {$lookup:{
                
                    from:"shifts",
                    localField:"shifts_id",
                    foreignField:"_id",
                    as:"shifts_data"
                
                    }},
                    
                    {$unwind:"$shifts_data"},
                
                
                {$project:{
                    _id:1,
                    doctor_name:"$doctor_data.name",
                    doctor_profile:"$doctor_data.picture",
                    patient_name:"$patient_data.name",
                    patient_token:"$patient_data.token",
                    doctor_token:"$doctor_data.token",
                    patient_id:"$patient_data._id",
                    patient_phone:"$patient_data.phone",
                    doctor_phone:"$doctor_data.phone",
                    doctor_id:"$doctor_data._id",
                    shift_time:"$shifts_data.time",
                    shift_day:"$shifts_data.day",
                    patient_Gender: "$patient_data.gender",
                    patient_Age: "$patient_data.age",
                    sequence_id:1,
                    appointment_date:1,
                    status:1,
                    is_reviewed:1,
                    create_date:1
                }}
            ]).then((appointment_data)=>{

                if(appointment_data){

                    res.send({
                        success:true,
                        message:"Successfully to fetch All Appointements for Patient",
                        record:appointment_data
                    })
                }else{
                    res.send({
                        success:false,
                        message:"Sorry! to fetch Appointements for Patient"
                    })
        
                }


            })
            
}





//Api get all appointments for doctor
exports.doctor_appointements = function(req, res){
    Appointment.aggregate([

        {
            $match: {
                "doctor_id": ObjectId(req.body.doctor_id)
            }
        },

        {$lookup:{
            
            from:"doctors",
            localField:"doctor_id",
            foreignField:"_id",
            as:"doctor_data"
        
            }},
            
            {$unwind:"$doctor_data"},
            
            {$lookup:{
            
            from:"patients",
            localField:"patient_id",
            foreignField:"_id",
            as:"patient_data"
        
            }},
            
            {$unwind:"$patient_data"},

            {$lookup:{
            
                from:"shifts",
                localField:"shifts_id",
                foreignField:"_id",
                as:"shifts_data"
            
                }},
                
                {$unwind:"$shifts_data"},
            
            
            {$project:{
                _id:1,
                doctor_name:"$doctor_data.name",
                patient_name:"$patient_data.name",
                patient_token:"$patient_data.token",
                doctor_token:"$doctor_data.token",
                patient_id:"$patient_data._id",
                doctor_id:"$doctor_data._id",
                patient_phone:"$patient_data.phone",
                doctor_phone:"$doctor_data.phone",
                patient_profile:"$patient_data.picture",
                shift_time:"$shifts_data.time",
                shift_day:"$shifts_data.day",
                patient_Gender: "$patient_data.gender",
                patient_Age: "$patient_data.age",
                sequence_id:1,
                appointment_date:1,
                status:1,
                create_date:1
                      
                }}
        
        ]).then((appointment_data)=>{

            if(appointment_data){

                res.send({
                    success:true,
                    message:"Successfully to fetch All Appointements for Doctor",
                    record:appointment_data
                })
            }else{
                res.send({
                    success:false,
                    message:"Sorry! to fetch Appointements for Doctor"
                })
    
            }


        })
        
}




exports.patient_transection = function(req, res){
    Payment.aggregate([

        {
            $match: {
                "patient_id": ObjectId(req.body.patient_id)
            }
        },

        {$lookup:{
            
            from:"doctors",
            localField:"doctor_id",
            foreignField:"_id",
            as:"doctor_data"
        
            }},
            
            {$unwind:"$doctor_data"},
            
            {$lookup:{
            
            from:"patients",
            localField:"patient_id",
            foreignField:"_id",
            as:"patient_data"
        
            }},
            
            {$unwind:"$patient_data"},
            
            
            {$project:{
                _id:1,
                doctor_name:"$doctor_data.name",
                patient_name:"$patient_data.name",
                amount:1,
                sequence_id:1,
                payment_method:1,
                sender_phone:1,
                reciver_phone:1,
                status:1,
                create_date:1
                      
                }}
        
        ]).then((payment_data)=>{
            if(payment_data){

                     res.send({
                    success:true,
                    message:"Successfully to fetch All  for Patient",
                    record:payment_data
                })
            }else{
                res.send({
                    success:false,
                    message:"Sorry! to fetch Transactions for Patient"
                })
    
            }

        })
}





exports.doctor_transection = function(req, res){
    Payment.aggregate([

        {
            $match: {
                "doctor_id": ObjectId(req.body.doctor_id)
            }
        },

        {$lookup:{
            
            from:"doctors",
            localField:"doctor_id",
            foreignField:"_id",
            as:"doctor_data"
        
            }},
            
            {$unwind:"$doctor_data"},
            
            {$lookup:{
            
            from:"patients",
            localField:"patient_id",
            foreignField:"_id",
            as:"patient_data"
        
            }},
            
            {$unwind:"$patient_data"},
            
            
            {$project:{
                _id:1,
                doctor_name:"$doctor_data.name",
                patient_name:"$patient_data.name",
                amount:1,
                sequence_id:1,
                payment_method:1,
                sender_phone:1,
                reciver_phone:1,
                status:1,
                create_date:1
                      
                }}
        
        ]).then((payment_data)=>{
            if(payment_data){

                     res.send({
                    success:true,
                    message:"Successfully to fetch All Transactions for Doctor",
                    record:payment_data
                })
            }else{
                res.send({
                    success:false,
                    message:"Sorry! to fetch Transactions for Doctor",n
                })
    
            }

        })
}

exports.booking_Appointement = function (req, res) {
    const appointmentDate = new Date(req.body.appointment_date);
    const formattedDate = new Intl.DateTimeFormat('en-GB', { day: '2-digit', month: 'long', year: 'numeric' }).format(appointmentDate);

    var appointment = new Appointment({
        reason: req.body.reason,
        sequence_id: Utils.get_unique_id(),
        status: 0,
        doctor_id: req.body.doctor_id,
        patient_id: req.body.patient_id,
        shifts_id: req.body.shifts_id,
        appointment_date: formattedDate // Store as "25 March 2025"
    });

    appointment.save().then((bookingappointment) => {
        if (bookingappointment) {
            res.send({
                success: true,
                message: "Successfully booked appointment",
                record: bookingappointment
            });
        } else {
            res.send({
                success: false,
                message: "Sorry! Booking appointment failed"
            });
        }
    }).catch((err) => {
        res.status(500).send({ success: false, message: "Server error", error: err.message });
    });
};


//Api pay payment doctor
exports.payPayement = function (req, res) {
           
                        var amount = req.body.amount
                        var payment = new Payment({
                            amount: amount,
                            sequence_id: Utils.get_unique_id(),
                            doctor_id:req.body.doctor_id,
                            patient_id:req.body.patient_id,
                            status: 1,
                            payment_method:"EVC-Plus"
                            
                        });
                
                        payment.save().then((admin) => {
                            if(bookingappointment){
                                res.send({
                                    success:true,
                                    message:"Successfully to Pay Payment",
                                    record:bookingappointment
                                })
                            }
                            else{
                                res.send({
                                    success:false,
                                    message:"Sorry! to Pay Payment Failed"
                                })
                            }
                        });

};

  

exports.bookAndPay = function (req, res) {
    // Marka hore, wax ka bixi lacag bixinta (Payment)
    var amount = req.body.amount;
    var payment = new Payment({
        amount: amount,
        sequence_id: Utils.get_unique_id(),
        doctor_id: req.body.doctor_id,
        patient_id: req.body.patient_id,
        sender_phone:req.body.sender_phone,
        reciver_phone:req.body.reciver_phone,
        status: 1, // Payment successful 
        payment_method: "EVC-Plus"
    });

    payment.save().then((savedPayment) => {
            if (!savedPayment) {
                return res.send({
                    success: false,
                    message: "Sorry! Payment failed"
                });
            }

            // Haddii Payment lagu guuleystay, samee appointment booking
            const appointmentDate = new Date(req.body.appointment_date);
            const formattedDate = new Intl.DateTimeFormat('en-GB', { day: '2-digit', month: 'long', year: 'numeric' }).format(appointmentDate);

            var appointment = new Appointment({
                reason: req.body.reason,
                sequence_id: Utils.get_unique_id(),
                status: 1,
                doctor_id: req.body.doctor_id,
                patient_id: req.body.patient_id,
                shifts_id: req.body.shifts_id,
                appointment_date: formattedDate // Store as "25 March 2025"
            });

            return appointment.save();
        })
        .then((savedAppointment) => {
            if (!savedAppointment) {
                return res.send({
                    success: false,
                    message: "Payment successful, but appointment booking failed"
                });
            }

            res.send({
                success: true,
                message: "Successfully paid & booked appointment",
                record: savedAppointment
            });
        })
        .catch((err) => {
            res.status(500).send({ success: false, message: "Server error", error: err.message });
        });
};



exports.getAll_Hospitals = function(req,res){
    Hospital.find().then((hospital_data)=>{
        if(hospital_data){
            res.send({
                success:true,
                message:"Successfully to fetch All Hospitals",
                record:hospital_data
            })
        }else{
            res.send({
                success:false,
                message:"Sorry! to fetch Hospitals"
            })
        }
    })
}



exports.shifts = function(req, res){
    Shifts.aggregate([

        {$match:{
            "doctor_id" : ObjectId(req.body.doctor_id),
            }
            },
            {
                $match: {
                    "day": "Saturday" // Match shifts where the day is Saturday
                }
            }
        
        ]).then((Saturday)=>{

            Shifts.aggregate([

                {$match:{
                    "doctor_id" : ObjectId(req.body.doctor_id),
                    }
                    },
                    {
                        $match: {
                            "day": "Sunday" // Match shifts where the day is Saturday
                        }
                    }
                
                ]).then((Sunday)=>{

                    Shifts.aggregate([

                        {$match:{
                            "doctor_id" : ObjectId(req.body.doctor_id),
                            }
                            },
                            {
                                $match: {
                                    "day": "Monday" // Match shifts where the day is Saturday
                                }
                            }
                        
                        ]).then((Monday)=>{
                            Shifts.aggregate([

                                {$match:{
                                    "doctor_id" : ObjectId(req.body.doctor_id),
                                    }
                                    },
                                    {
                                        $match: {
                                            "day": "Tuesday" // Match shifts where the day is Saturday
                                        }
                                    }
                                
                                ]).then((Tuesday)=>{
                                    Shifts.aggregate([

                                        {$match:{
                                            "doctor_id" : ObjectId(req.body.doctor_id),
                                            }
                                            },
                                            {
                                                $match: {
                                                    "day": "Wednesday" // Match shifts where the day is Saturday
                                                }
                                            }
                                        
                                        ]).then((Wednesday)=>{
                                            Shifts.aggregate([

                                                {$match:{
                                                    "doctor_id" : ObjectId(req.body.doctor_id),
                                                    }
                                                    },
                                                    {
                                                        $match: {
                                                            "day": "Thursday" // Match shifts where the day is Saturday
                                                        }
                                                    }
                                                
                                                ]).then((Thursday)=>{
                                                    Shifts.aggregate([

                                                        {$match:{
                                                            "doctor_id" : ObjectId(req.body.doctor_id),
                                                            }
                                                            },
                                                            {
                                                                $match: {
                                                                    "day": "Friday" // Match shifts where the day is Saturday
                                                                }
                                                            }
                                                        
                                                        ]).then((Friday)=>{
                            
       

            
            if(Saturday && Sunday && Monday && Tuesday && Wednesday && Thursday || Friday){
                res.send({
                    success:true,
                    message:"Successfully to  Fetch all shifts",
                    Saturday:Saturday,
                    Sunday:Sunday,
                    Monday:Monday,
                    Tuesday:Tuesday,
                    Wednesday:Wednesday,
                    Thursday:Thursday,
                    Friday:Friday
                })
            }
            else{
                res.send({
                    success:false,
                    message:"Failed to fetch all shifts"
                })
            }

        })
    })
})
})
})
})
})
}



exports.check_shifts = function(req, res) {
    Appointment.findOne({ shifts_id: req.body.shifts_id, appointment_date: req.body.appointment_date }).then((shiftes_appointment) => {
            if (shiftes_appointment) {
                return res.send({
                    success: false,
                    message: "The shift has already been booked"
                });
            }
            else{   
                    let appointmentDate = new Date(req.body.appointment_date);
                    let currentDate = new Date(); 
                    if (appointmentDate < currentDate.setHours(0, 0, 0, 0)) {
                        return res.send({
                            success: false,
                            message: "The date you selected has already passed"
                        });
                    }
                    else{
                       Shifts.findOne({ _id: req.body.shifts_id }).then((shiftes) => {

                        let shiftTime = shiftes.time; 
                        let currentTime = new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true });
                        let shiftDateTime = new Date(`${appointmentDate.toDateString()} ${shiftTime}`);
                        console.log("shiftDateTime", shiftDateTime)
                        let currentDateTime = new Date(`${new Date().toDateString()} ${currentTime}`);
                        console.log("currentDateTime", currentDateTime)

                        if (currentDateTime > shiftDateTime) {
                            return res.send({
                                success: false,
                                message: "The time you selected has already passed"
                            });
                        }
                        else{
                            return res.send({
                                success: true,
                                message: "You can book this shifts"
                            });
                        }
                    });
                    }
                
            } 
        })
        .catch((err) => {
            console.error(err);
            res.status(500).send({
                success: false,
                message: "Waxaa dhacay qalad"
            });
        });
};





exports.Saturday_Shifts = async function(req, res) {
    try {
        const doctorId = ObjectId(req.body.doctor_id);
        const appointmentDate = new Date(req.body.appointment_date);
        const currentDate = new Date();
        currentDate.setHours(0, 0, 0, 0); // Set to start of today

        // Haddii appointment_date la dhafay, soo celin waxba
        if (appointmentDate < currentDate) {
            return res.send({
                success: false,
                message: "The date you selected has already passed"
            });
        }

        // List of days
        const daysOfWeek = ["Saturday"];

        // Get all shifts of the doctor
        const allShifts = await Shifts.find({ doctor_id: doctorId });

        // Filter each shift
        const availableShiftsByDay = {};

        for (let day of daysOfWeek) {
            // Filter shifts by day
            const dayShifts = allShifts.filter(shift => shift.day === day);

            const filteredShifts = [];

            for (let shift of dayShifts) {
                const shiftAlreadyBooked = await Appointment.findOne({
                    shifts_id: shift._id,
                    appointment_date: req.body.appointment_date
                });

                if (shiftAlreadyBooked) continue; // Skip if booked

                // Compare times only if appointment date is today
                let shiftTime = shift.time;
                let now = new Date();
                let shiftDateTime = new Date(`${appointmentDate.toDateString()} ${shiftTime}`);
                let nowDateTime = new Date();
                // In local time waa ok lakin In Server ka 3 hours ayuu danbeyaa sidas dartee use this
                nowDateTime.setHours(nowDateTime.getHours() + 3);

                if (
                    appointmentDate.toDateString() === now.toDateString() &&
                    nowDateTime > shiftDateTime
                ) {
                    continue; // Skip if time passed today
                }

                // Shift is available
                filteredShifts.push(shift);
            }

            availableShiftsByDay[day] = filteredShifts;
        }

        res.send({
            success: true,
            message: "Available shifts fetched successfully",
            shifts: availableShiftsByDay
        });

    } catch (error) {
        console.error(error);
        res.status(500).send({
            success: false,
            message: "Waxaa dhacay qalad server-ka"
        });
    }
};


exports.Sunday_Shifts = async function(req, res) {
    try {
        const doctorId = ObjectId(req.body.doctor_id);
        const appointmentDate = new Date(req.body.appointment_date);
        const currentDate = new Date();
        currentDate.setHours(0, 0, 0, 0); // Set to start of today

        // Haddii appointment_date la dhafay, soo celin waxba
        if (appointmentDate < currentDate) {
            return res.send({
                success: false,
                message: "The date you selected has already passed"
            });
        }

        // List of days
        const daysOfWeek = ["Sunday"];

        // Get all shifts of the doctor
        const allShifts = await Shifts.find({ doctor_id: doctorId });

        // Filter each shift
        const availableShiftsByDay = {};

        for (let day of daysOfWeek) {
            // Filter shifts by day
            const dayShifts = allShifts.filter(shift => shift.day === day);

            const filteredShifts = [];

            for (let shift of dayShifts) {
                const shiftAlreadyBooked = await Appointment.findOne({
                    shifts_id: shift._id,
                    appointment_date: req.body.appointment_date
                });

                if (shiftAlreadyBooked) continue; // Skip if booked

                // Compare times only if appointment date is today
                let shiftTime = shift.time;
                let now = new Date();
                let shiftDateTime = new Date(`${appointmentDate.toDateString()} ${shiftTime}`);
                let nowDateTime = new Date();
                 // In local time waa ok lakin In Server ka 3 hours ayuu danbeyaa sidas dartee use this
                 nowDateTime.setHours(nowDateTime.getHours() + 3);

                if (
                    appointmentDate.toDateString() === now.toDateString() &&
                    nowDateTime > shiftDateTime
                ) {
                    continue; // Skip if time passed today
                }

                // Shift is available
                filteredShifts.push(shift);
            }

            availableShiftsByDay[day] = filteredShifts;
        }

        res.send({
            success: true,
            message: "Available shifts fetched successfully",
            shifts: availableShiftsByDay
        });

    } catch (error) {
        console.error(error);
        res.status(500).send({
            success: false,
            message: "Waxaa dhacay qalad server-ka"
        });
    }
};


exports.Monday_Shifts = async function(req, res) {
    try {
        const doctorId = ObjectId(req.body.doctor_id);
        const appointmentDate = new Date(req.body.appointment_date);
        const currentDate = new Date();
        currentDate.setHours(0, 0, 0, 0); // Set to start of today

        // Haddii appointment_date la dhafay, soo celin waxba
        if (appointmentDate < currentDate) {
            return res.send({
                success: false,
                message: "The date you selected has already passed"
            });
        }

        // List of days
        const daysOfWeek = ["Monday"];

        // Get all shifts of the doctor
        const allShifts = await Shifts.find({ doctor_id: doctorId });

        // Filter each shift
        const availableShiftsByDay = {};

        for (let day of daysOfWeek) {
            // Filter shifts by day
            const dayShifts = allShifts.filter(shift => shift.day === day);

            const filteredShifts = [];

            for (let shift of dayShifts) {
                const shiftAlreadyBooked = await Appointment.findOne({
                    shifts_id: shift._id,
                    appointment_date: req.body.appointment_date
                });

                if (shiftAlreadyBooked) continue; // Skip if booked

                // Compare times only if appointment date is today
                let shiftTime = shift.time;
                let now = new Date();
                let shiftDateTime = new Date(`${appointmentDate.toDateString()} ${shiftTime}`);
                let nowDateTime = new Date();
                 // In local time waa ok lakin In Server ka 3 hours ayuu danbeyaa sidas dartee use this
                 nowDateTime.setHours(nowDateTime.getHours() + 3);

                if (
                    appointmentDate.toDateString() === now.toDateString() &&
                    nowDateTime > shiftDateTime
                ) {
                    continue; // Skip if time passed today
                }

                // Shift is available
                filteredShifts.push(shift);
            }

            availableShiftsByDay[day] = filteredShifts;
        }

        res.send({
            success: true,
            message: "Available shifts fetched successfully",
            shifts: availableShiftsByDay
        });

    } catch (error) {
        console.error(error);
        res.status(500).send({
            success: false,
            message: "Waxaa dhacay qalad server-ka"
        });
    }
};



exports.Tuesday_Shifts = async function(req, res) {
    try {
        const doctorId = ObjectId(req.body.doctor_id);
        const appointmentDate = new Date(req.body.appointment_date);
        const currentDate = new Date();
        currentDate.setHours(0, 0, 0, 0); // Set to start of today

        // Haddii appointment_date la dhafay, soo celin waxba
        if (appointmentDate < currentDate) {
            return res.send({
                success: false,
                message: "The date you selected has already passed"
            });
        }

        // List of days
        const daysOfWeek = ["Tuesday"];

        // Get all shifts of the doctor
        const allShifts = await Shifts.find({ doctor_id: doctorId });

        // Filter each shift
        const availableShiftsByDay = {};

        for (let day of daysOfWeek) {
            // Filter shifts by day
            const dayShifts = allShifts.filter(shift => shift.day === day);

            const filteredShifts = [];

            for (let shift of dayShifts) {
                const shiftAlreadyBooked = await Appointment.findOne({
                    shifts_id: shift._id,
                    appointment_date: req.body.appointment_date
                });

                if (shiftAlreadyBooked) continue; // Skip if booked

                // Compare times only if appointment date is today
                let shiftTime = shift.time;
                let now = new Date();
                let shiftDateTime = new Date(`${appointmentDate.toDateString()} ${shiftTime}`);
                let nowDateTime = new Date();
                 // In local time waa ok lakin In Server ka 3 hours ayuu danbeyaa sidas dartee use this
                 nowDateTime.setHours(nowDateTime.getHours() + 3);

                if (
                    appointmentDate.toDateString() === now.toDateString() &&
                    nowDateTime > shiftDateTime
                ) {
                    continue; // Skip if time passed today
                }

                // Shift is available
                filteredShifts.push(shift);
            }

            availableShiftsByDay[day] = filteredShifts;
        }

        res.send({
            success: true,
            message: "Available shifts fetched successfully",
            shifts: availableShiftsByDay
        });

    } catch (error) {
        console.error(error);
        res.status(500).send({
            success: false,
            message: "Waxaa dhacay qalad server-ka"
        });
    }
};



exports.Wednesday_Shifts = async function(req, res) {
    try {
        const doctorId = ObjectId(req.body.doctor_id);
        const appointmentDate = new Date(req.body.appointment_date);
        const currentDate = new Date();
        currentDate.setHours(0, 0, 0, 0); // Set to start of today

        // Haddii appointment_date la dhafay, soo celin waxba
        if (appointmentDate < currentDate) {
            return res.send({
                success: false,
                message: "The date you selected has already passed"
            });
        }

        // List of days
        const daysOfWeek = ["Wednesday"];

        // Get all shifts of the doctor
        const allShifts = await Shifts.find({ doctor_id: doctorId });

        // Filter each shift
        const availableShiftsByDay = {};

        for (let day of daysOfWeek) {
            // Filter shifts by day
            const dayShifts = allShifts.filter(shift => shift.day === day);

            const filteredShifts = [];

            for (let shift of dayShifts) {
                const shiftAlreadyBooked = await Appointment.findOne({
                    shifts_id: shift._id,
                    appointment_date: req.body.appointment_date
                });

                if (shiftAlreadyBooked) continue; // Skip if booked

                // Compare times only if appointment date is today
                let shiftTime = shift.time;
                let now = new Date();
                let shiftDateTime = new Date(`${appointmentDate.toDateString()} ${shiftTime}`);
                let nowDateTime = new Date();
                 // In local time waa ok lakin In Server ka 3 hours ayuu danbeyaa sidas dartee use this
                 nowDateTime.setHours(nowDateTime.getHours() + 3);

                if (
                    appointmentDate.toDateString() === now.toDateString() &&
                    nowDateTime > shiftDateTime
                ) {
                    continue; // Skip if time passed today
                }

                // Shift is available
                filteredShifts.push(shift);
            }

            availableShiftsByDay[day] = filteredShifts;
        }

        res.send({
            success: true,
            message: "Available shifts fetched successfully",
            shifts: availableShiftsByDay
        });

    } catch (error) {
        console.error(error);
        res.status(500).send({
            success: false,
            message: "Waxaa dhacay qalad server-ka"
        });
    }
};



exports.Thursday_Shifts = async function(req, res) {
    try {
        const doctorId = ObjectId(req.body.doctor_id);
        const appointmentDate = new Date(req.body.appointment_date);
        const currentDate = new Date();
        currentDate.setHours(0, 0, 0, 0); // Set to start of today

        // Haddii appointment_date la dhafay, soo celin waxba
        if (appointmentDate < currentDate) {
            return res.send({
                success: false,
                message: "The date you selected has already passed"
            });
        }

        // List of days
        const daysOfWeek = ["Thursday"];

        // Get all shifts of the doctor
        const allShifts = await Shifts.find({ doctor_id: doctorId });

        // Filter each shift
        const availableShiftsByDay = {};

        for (let day of daysOfWeek) {
            // Filter shifts by day
            const dayShifts = allShifts.filter(shift => shift.day === day);

            const filteredShifts = [];

            for (let shift of dayShifts) {
                const shiftAlreadyBooked = await Appointment.findOne({
                    shifts_id: shift._id,
                    appointment_date: req.body.appointment_date
                });

                if (shiftAlreadyBooked) continue; // Skip if booked

                // Compare times only if appointment date is today
                let shiftTime = shift.time;
                let now = new Date();
                let shiftDateTime = new Date(`${appointmentDate.toDateString()} ${shiftTime}`);
                let nowDateTime = new Date();
                 // In local time waa ok lakin In Server ka 3 hours ayuu danbeyaa sidas dartee use this
                 nowDateTime.setHours(nowDateTime.getHours() + 3);

                if (
                    appointmentDate.toDateString() === now.toDateString() &&
                    nowDateTime > shiftDateTime
                ) {
                    continue; // Skip if time passed today
                }

                // Shift is available
                filteredShifts.push(shift);
            }

            availableShiftsByDay[day] = filteredShifts;
        }

        res.send({
            success: true,
            message: "Available shifts fetched successfully",
            shifts: availableShiftsByDay
        });

    } catch (error) {
        console.error(error);
        res.status(500).send({
            success: false,
            message: "Waxaa dhacay qalad server-ka"
        });
    }
};


exports.Friday_Shifts = async function(req, res) {
    try {
        const doctorId = ObjectId(req.body.doctor_id);
        const appointmentDate = new Date(req.body.appointment_date);
        const currentDate = new Date();
        currentDate.setHours(0, 0, 0, 0); // Set to start of today

        // Haddii appointment_date la dhafay, soo celin waxba
        if (appointmentDate < currentDate) {
            return res.send({
                success: false,
                message: "The date you selected has already passed"
            });
        }

        // List of days
        const daysOfWeek = ["Friday"];

        // Get all shifts of the doctor
        const allShifts = await Shifts.find({ doctor_id: doctorId });

        // Filter each shift
        const availableShiftsByDay = {};

        for (let day of daysOfWeek) {
            // Filter shifts by day
            const dayShifts = allShifts.filter(shift => shift.day === day);

            const filteredShifts = [];

            for (let shift of dayShifts) {
                const shiftAlreadyBooked = await Appointment.findOne({
                    shifts_id: shift._id,
                    appointment_date: req.body.appointment_date
                });

                if (shiftAlreadyBooked) continue; // Skip if booked

                // Compare times only if appointment date is today
                let shiftTime = shift.time;
                let now = new Date();
                let shiftDateTime = new Date(`${appointmentDate.toDateString()} ${shiftTime}`);
                let nowDateTime = new Date();
                 // In local time waa ok lakin In Server ka 3 hours ayuu danbeyaa sidas dartee use this
                 nowDateTime.setHours(nowDateTime.getHours() + 3);

                if (
                    appointmentDate.toDateString() === now.toDateString() &&
                    nowDateTime > shiftDateTime
                ) {
                    continue; // Skip if time passed today
                }

                // Shift is available
                filteredShifts.push(shift);
            }

            availableShiftsByDay[day] = filteredShifts;
        }

        res.send({
            success: true,
            message: "Available shifts fetched successfully",
            shifts: availableShiftsByDay
        });

    } catch (error) {
        console.error(error);
        res.status(500).send({
            success: false,
            message: "Waxaa dhacay qalad server-ka"
        });
    }
};



exports.adds = function(req, res){
    Adds.aggregate([
        {$match:{"status":1}}   
        ]).then((adds_data)=>{
        if(adds_data){
            res.send({
                success:true,
                message:"Successfully to fetch all Adds",
                record:adds_data
            })
        }else{
            res.send({
                success:false,
                message:"Sorry! to fetch Adds"
            })
        }

    })

}




exports.selfmanagment = function(req, res){
    SelfManagment.aggregate([
        {$match:{"status":1}}   
        ]).then((selfmanagment_data)=>{
        if(selfmanagment_data){
            res.send({
                success:true,
                message:"Successfully to fetch all Self Managment",
                record:selfmanagment_data
            })
        }else{
            res.send({
                success:false,
                message:"Sorry! to fetch Self Managment"
            })
        }

    })

}




exports.updateProfile = function (req, res) {
    var profile_file = req.files;
    if (!profile_file || profile_file == '' || profile_file == 'undefined') {
        // Haddii file la'aan update, waa la diidi karaa ama fariin la dirayaa
        return res.send({
            success: false,
            message: "No image uploaded"
        });
    } else {
        // File waa la upload gareeyey – sawirka update garee kaliya
        Patient.findById(req.body.patient_id).then((user) => {
            if (user.picture) {
                Utils.deleteImageFromFolderTosaveNewOne(user.picture, 1);
            }
            var image_name = user._id + "_" + Utils.tokenGenerator(4) + '.jpg';
            var url = "./uploads/admin_profile/" + image_name;

            fs.readFile(req.files[0].path, function (err, data) {
                if (err) {
                    console.error("Error reading file:", err);
                    return res.send({
                        success: false,
                        message: "Failed to read uploaded file"
                    });
                }

                fs.writeFile(url, data, 'binary', function (err) {
                    if (err) {
                        console.error("Error writing file:", err);
                        return res.send({
                            success: false,
                            message: "Failed to save profile picture"
                        });
                    }

                    fs.unlink(req.files[0].path, function (err) {
                        if (err) console.error("Error deleting temp file:", err);
                    });

                    // Update only picture field
                    Patient.findByIdAndUpdate(
                        req.body.patient_id,
                        { picture: "admin_profile/" + image_name, name: req.body.name, email: req.body.email, phone: req.body.phone, address: req.body.address, gender: req.body.gender, age: req.body.age, extra_detail: req.body.extra_detail, user_name: req.body.user_name, PassWord: req.body.PassWord, password: Bcrypt.hashSync(req.body.PassWord, 10) },
                        { useFindAndModify: false }
                    ).then((data) => {
                        res.send({
                            success: true,
                            message: "Profile picture updated successfully",
                            picture: "admin_profile/" + image_name
                        });
                    }).catch((err) => {
                        res.send({
                            success: false,
                            message: "Error while updating profile picture"
                        });
                    });
                });
            });
        });
    }
};



exports.docAndpat = function(req, res){
    Doctor.find({}).then((doctorData)=>{
        Patient.find({}).then((patientData)=>{
            if(doctorData && patientData){
                
                res.send({
                    success:true,
                    message:"Successfully to fetch all Doctors And Patients",
                    record:doctorData,patientData
                })

            }else{
                res.send({
                    success:false,
                    message:"Sorry! to fetch  Doctors And Patients"
                })
            }

        })
    })

}



 
//Api get all appointments for doctor
exports.conseltaion = function(req, res){
    Appointment.aggregate([

        {
            $match: {
                doctor_id: ObjectId(req.body.doctor_id),
                status: 1
            }
        },

        {$lookup:{
            
            from:"doctors",
            localField:"doctor_id",
            foreignField:"_id",
            as:"doctor_data"
        
            }},
            
            {$unwind:"$doctor_data"},
            
            {$lookup:{
            
            from:"patients",
            localField:"patient_id",
            foreignField:"_id",
            as:"patient_data"
        
            }},
            
            {$unwind:"$patient_data"},

            {$lookup:{
            
                from:"shifts",
                localField:"shifts_id",
                foreignField:"_id",
                as:"shifts_data"
            
                }},
                
                {$unwind:"$shifts_data"},
            
            
            {$project:{
                _id:1,
                doctor_name:"$doctor_data.name",
                doctor_id:"$doctor_data._id",
                patient_name:"$patient_data.name",
                patient_id:"$patient_data._id",
                patient_token:"$patient_data.token",
                doctor_token:"$doctor_data.token",
                patient_profile:"$patient_data.picture",
                shift_time:"$shifts_data.time",
                shift_day:"$shifts_data.day",
                sequence_id:1,
                appointment_date:1,
                status:1,
                create_date:1
                      
                }}
        
        ]).then((conseltation_data)=>{

            if(conseltation_data){

                res.send({
                    success:true,
                    message:"Successfully to fetch All Patients pending conseltation",
                    record:conseltation_data
                })
            }else{
                res.send({
                    success:false,
                    message:"Sorry! to fetch  Patients pending conseltation"
                })
    
            }


        })
        
}



exports.save_conseltaion = function(req, res){

    var roomID = req.body.roomID
    var conseltaion = new Conseltaion({
        roomID:roomID,
        sequence_id:Utils.get_unique_id(),
        doctor_id:req.body.doctor_id,
        patient_id:req.body.patient_id,
        status:"pending",
    
    });

    conseltaion.save().then((conseltaion)=>{
        if(conseltaion){
            res.send({
                success:true,
                message:"successfully to register conseltation",
                record:conseltaion
            })
        }
        else{
            res.send({
                success:false,
                message:"Sorry! not register conseltation",
            })

        }

    })

}



exports.update_conseltaion = function(req,res){
    Conseltaion.findOneAndUpdate({roomID:req.body.roomID}, { $set: { status: req.body.status } }).then((updateConsel)=>{
        if(updateConsel){
            res.send({
                success:true,
                message:"Successfully to update conseltation status",
                record:updateConsel
            })
        }else{
            res.send({
                success:false,
                message:"Sorry! not update conseltation status"
            })
        }

    })
}





exports.update_token = function(req, res){
    Doctor.findOne({ _id:req.body._id}).then((doctor) => {
        if(doctor){
            Doctor.findOneAndUpdate({ _id: req.body._id }, { $set: { token: req.body.token }}, { new: true }).then((data_doctor) => {
                console.log("gggggg",data_doctor)

                res.send({
                    success:true,
                    message:"Successfully to Update Doctor",
                    record:data_doctor
                })
            })
        }else{
            Patient.findOne({ _id: req.body._id}).then((patient) => {
                if(patient){
                    Patient.findOneAndUpdate({ _id: req.body._id }, { $set: { token: req.body.token }}, { new: true }).then((data_patient) => {
                        res.send({
                            success:true,
                            message:"Successfully to Update Patient",
                            record:data_patient
                        })
                    })
                }else{
                    res.send({
                        success:false,
                        message:"Invalid Email or Password"
                    })
                }
            });
          
        }
    })
}




exports.re_appointment = function (req, res) {
    Appointment.findOne({_id:req.body._id }).then((re_appointment) => {
      if (re_appointment) {
        if(req.body.status==2){
            Appointment.findOneAndUpdate(
                { _id: req.body._id },
                { $set: { status: req.body.status } },
                { new: true }
              ).then((data_re_appointment) => {
        
                res.send({
                  success: true,
                  message: "Successfully to Compelete appointement",
                  record: data_re_appointment,
                });
              });
        }
        else if(req.body.status==4){
            Appointment.findOneAndUpdate(
              { _id: req.body._id },
              { $set: { status: req.body.status,appointment_date: req.body.appointment_date, shifts_id:req.body.shifts_id,reminderSent:false} },
              { new: true }
            ).then((data_re_appointment) => {
      
              res.send({
                success: true,
                message: "Successfully to re_appointement",
                record: data_re_appointment,
              });
            });
        }
    
      } else {
        res.send({
          success: false,
          message: "Failed to re_appointement",
        });
      }
    });
  };





  exports.feedbackPatient = function (req, res) {
                        var comments = req.body.comments
                        var feedback = new Feedback({
                            comments: comments,
                            sequence_id: Utils.get_unique_id(),
                            doctor_id:req.body.doctor_id,
                            patient_id:req.body.patient_id,
                            appointment_id:req.body.appointment_id,
                            rating:req.body.rating,
                        });
                        feedback.save().then((feedback) => {
                            if(feedback){
                                res.send({
                                    success:true,
                                    message:"Successfully to review this doctor",
                                    record:feedback
                                });
                                Appointment.findOneAndUpdate(
                                    { _id: feedback.appointment_id },
                                    { $set: { is_reviewed: true } },
                                    { new: true }
                                ).then((updated_appointment) => {
                                    if (updated_appointment) {
                                        console.log("Appointment updated successfully");
                                    }
                                });
                            }
                            else{
                                res.send({
                                    success:false,
                                    message:"Field to review this doctor",
                                })
                            }
                           
                        });


};




exports.filter_Hospital = function(req, res){
    Doctor.aggregate([

        {
            $match: {
                "hospital_id": ObjectId(req.body.hospital_id)
            }
        },

        {$lookup:{
            
            from:"hospitals",
            localField:"hospital_id",
            foreignField:"_id",
            as:"hospital_data"
        
            }},
            
            {$unwind:"$hospital_data"},
            
            {$lookup:{
            
            from:"specialities",
            localField:"speciality_id",
            foreignField:"_id",
            as:"speciality_data"
        
            }},
            
            {$unwind:"$speciality_data"},
            
            
            {$project:{
                _id: 1,
                sequence_id: 1,
                name: 1,
                picture: 1,
                phone: 1,
                email: 1,
                rating:1,
                hospital_name: "$hospital_data.name",
                countries: 1,
                speciality:"$speciality_data.name",
                experience_years: 1,
                consultation_fee: 1,
                status: 1,
                create_date: 1

                }}
        
        ]).then((doctor_data)=>{

            if(doctor_data){

                res.send({
                    success:true,
                    message:"Successfully to fetch All doctor register this Hospital",
                    record:doctor_data
                })
            }else{
                res.send({
                    success:false,
                    message:"Sorry! to fetch Doctors to register this hospital"
                })
    
            }

        
    })

}




exports.filter_Speciality = function(req, res){
    Doctor.aggregate([

        {
            $match: {
                "speciality_id": ObjectId(req.body.speciality_id)
            }
        },

        {$lookup:{
            
            from:"hospitals",
            localField:"hospital_id",
            foreignField:"_id",
            as:"hospital_data"
        
            }},
            
            {$unwind:"$hospital_data"},
            
            {$lookup:{
            
            from:"specialities",
            localField:"speciality_id",
            foreignField:"_id",
            as:"speciality_data"
        
            }},
            
            {$unwind:"$speciality_data"},
            
            
            {$project:{
                _id: 1,
                sequence_id: 1,
                name: 1,
                picture: 1,
                phone: 1,
                email: 1,
                rating: 1,
                hospital_name: "$hospital_data.name",
                countries: 1,
                speciality:"$speciality_data.name",
                experience_years: 1,
                consultation_fee: 1,
                status: 1,
                create_date: 1
                      
                }}
        
        ]).then((doctor_data)=>{

            if(doctor_data){

                res.send({
                    success:true,
                    message:"Successfully to fetch All doctor register this Speciality",
                    record:doctor_data
                })
            }else{
                res.send({
                    success:false,
                    message:"Sorry! to fetch Doctors to register this Speciality"
                })
    
            }

        
    })

}

  


exports.getAll_Speciality = function(req,res){
    Speciality.find().then((speciality_data)=>{
        if(speciality_data){
            res.send({
                success:true,
                message:"Successfully to fetch All Speciality",
                record:speciality_data
            })
        }else{
            res.send({
                success:false,
                message:"Sorry! to fetch Speciality"
            })
        }
    })
}



// abtiga aa qoray .............


exports.save_prescription = function(req, res) {
    try {
        // Validate required fields
        if (!req.body.medicines || !Array.isArray(req.body.medicines)) {
            return res.status(400).send({
                success: false,
                message: "Medicines array is required"
            });
        }

        // Validate each medicine in the array
        const medicinesValidation = req.body.medicines.every(med => {
            return med.medicine_name && med.dosage && med.duration && med.frequency;
        });

        if (!medicinesValidation) {
            return res.status(400).send({
                success: false,
                message: "Each medicine must have name, dosage, duration and frequency"
            });
        }
        

        // Create the prescription
        const prescription = new Prescription({
            medicines: req.body.medicines.map(med => ({
                medicine_name: med.medicine_name,
                dosage: med.dosage,
                duration: med.duration,
                frequency: med.frequency
            })),
            sequence_id: Utils.get_unique_id(),
            patient_id: req.body.patient_id,
            doctor_id: req.body.doctor_id,
            appointment_id: req.body.appointment_id,
            extra_detail: req.body.extra_detail
        });

        // First get patient and doctor details
        Promise.all([
            Patient.findById(req.body.patient_id),
            Doctor.findById(req.body.doctor_id)
        ])
        .then(([patient, doctor]) => {
            if (!patient) {
                throw new Error('Patient not found');
            }
            if (!doctor) {
                throw new Error('Doctor not found');
            }

            // Save prescription
            return prescription.save().then(savedPrescription => {
    
                return res.status(201).send({
                    success: true,
                    message: "Prescription registered successfully",
                    record: savedPrescription
                });
            });
        })
        .catch(err => {
            console.error("Save error:", err);
            res.status(500).send({
                success: false,
                message: "Failed to save prescription",
                error: err.message
            });
        });
    } catch (err) {
        console.error("Unexpected error:", err);
        res.status(500).send({
            success: false,
            message: "Internal server error",
            error: err.message
        });
    }
};


//Api get all prescriptions patient
exports.patient_prescription = function(req, res){
    Prescription.aggregate([

        {
            $match: {
                "patient_id": ObjectId(req.body.patient_id),
                 "doctor_id": ObjectId(req.body.doctor_id),
                 "appointment_id": ObjectId(req.body.appointment_id),
            }
        },

        {$lookup:{
            
            from:"doctors",
            localField:"doctor_id",
            foreignField:"_id",
            as:"doctor_data"
        
            }},
            
            {$unwind:"$doctor_data"},
            
            {$lookup:{
            
            from:"patients",
            localField:"patient_id",
            foreignField:"_id",
            as:"patient_data"
        
            }},
            
            {$unwind:"$patient_data"},

            {$lookup:{
            
                from:"appointments",
                localField:"appointment_id",
                foreignField:"_id",
                as:"appointment_data"
            
                }},
                
                {$unwind:"$appointment_data"},
                {
                    $lookup: {
                        from: "shifts",  
                        localField: "appointment_data.shifts_id",  
                        foreignField: "_id",
                        as: "shifts_data"
                    }
                },
                { $unwind: "$shifts_data" },
            
            
            {$project:{
                _id:1,
                medicines: 1,
                doctor_name:"$doctor_data.name",
                patient_name:"$patient_data.name",
                patient_token:"$patient_data.token",
                doctor_token:"$doctor_data.token",
                patient_id:"$patient_data._id",
                doctor_id:"$doctor_data._id",
                appointment_id:"$appointment_data._id",
                shift_time:"$shifts_data.time",
                shift_day:"$shifts_data.day",
                patient_Gender: "$patient_data.gender",
                patient_Age: "$patient_data.age",
                doctor_phone:"$patient_data.phone",
                patient_phone:"$patient_data.phone",
                sequence_id:1,
                appointment_date:1,
                status:1,
                create_date:1,
                extra_detail:1
                      
                }}
        
        ]).then((appointment_data)=>{

            if(appointment_data){

                res.send({
                    success:true,
                    message:"Successfully to fetch All prescriptions for Patient",
                    record:appointment_data
                })
            }else{
                res.send({
                    success:false,
                    message:"Sorry! to fetch prescriptions for Patient"
                })
    
            }


        })
        
}





//Api get all prescriptions doctor
exports.doctor_prescriptions = function(req, res){
    Prescription.aggregate([

        {
            $match: {
                  "patient_id": ObjectId(req.body.patient_id),
                 "doctor_id": ObjectId(req.body.doctor_id),
                 "appointment_id": ObjectId(req.body.appointment_id),
            }
        },
        {$lookup:{
            from:"doctors",
            localField:"doctor_id",
            foreignField:"_id",
            as:"doctor_data"
        }},
        
        {$unwind:"$doctor_data"},
        
        {$lookup:{
            from:"patients",
            localField:"patient_id",
            foreignField:"_id",
            as:"patient_data"
        }},
        
        {$unwind:"$patient_data"},

        {$lookup:{
            from:"appointments",
            localField:"appointment_id",
            foreignField:"_id",
            as:"appointment_data"
        }},
        
        {$unwind:"$appointment_data"},

        {$lookup:{
            from:"shifts",
            localField:"appointment_data.shifts_id",
            foreignField:"_id",
            as:"shifts_data"
        }},
        
        {$unwind:"$shifts_data"},
        
        {$project:{
            _id:1,
            medicines: 1,
            doctor_name:"$doctor_data.name",
            patient_name:"$patient_data.name",
            patient_token:"$patient_data.token",
            doctor_token:"$doctor_data.token",
            patient_id:"$patient_data._id",
            doctor_id:"$doctor_data._id",
            appointment_id:"$appointment_data._id",
            patient_phone:"$patient_data.phone",
            doctor_phone:"$doctor_data.phone",
            patient_profile:"$patient_data.picture",
            patient_Gender: "$patient_data.gender",
            patient_Age: "$patient_data.age",
             shift_time:"$shifts_data.time",
             shift_day:"$shifts_data.day",
            sequence_id:1,
            dosage:1,
            duration:1,
            medicine_name:1,
            status:1,
            create_date:1          
        }}
        
    ]).then((prescription_data)=>{
        console.log("dataaaa",prescription_data)
        if(prescription_data){
            res.send({
                success:true,
                message:"Successfully to fetch All Appointements for Doctor",
                record:prescription_data
            })
        }else{
            res.send({
                success:false,
                message:"Sorry! to fetch Appointements for Doctor"
            })
        }
    })
}



// labs 

exports.save_labs_record = function(req, res) {
    var report_file = req.files;

    // Validate file upload
    if (!report_file || report_file == '' || report_file == 'undefined' || !report_file[0]) {
        return res.send({
            success: false,
            message: "No lab report file uploaded"
        });
    }

    // Validate file type
    const allowedTypes = ['.jpg', '.jpeg', '.png'];
    const fileExtension = path.extname(report_file[0].originalname).toLowerCase();
    if (!allowedTypes.includes(fileExtension)) {
        return res.send({
            success: false,
            message: "Invalid file type. Allowed types: JPG, PNG"
        });
    }

    // Validate file size (5MB limit)
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (report_file[0].size > maxSize) {
        return res.send({
            success: false,
            message: "File size too large. Maximum size is 5MB"
        });
    }

    // Ensure upload directory exists
    const uploadDir = "./uploads/lab_reports/";
    if (!fs.existsSync(uploadDir)) {
        fs.mkdirSync(uploadDir, { recursive: true });
    }

    // first check if appointment already has lab
        Labs.findOne({ appointment_id: req.body.appointment_id })
            .then(existingLab => {
                if (existingLab) {
                    return res.send({
                        success: false,
                        message: "A lab record already exists for this appointment"
                    });
                }

                // Generate unique filename
                const sequenceId = Utils.get_unique_id();
                const fileName = `lab_report_${sequenceId}${fileExtension}`;
                const url = "./uploads/lab_reports/" + fileName;

                fs.readFile(report_file[0].path, function(err, data) {
                    if (err) {
                        console.error("Error reading file:", err);
                        return res.send({
                            success: false,
                            message: "Failed to read uploaded file"
                        });
                    }

                    fs.writeFile(url, data, 'binary', function(err) {
                        if (err) {
                            console.error("Error writing file:", err);
                            return res.send({
                                success: false,
                                message: "Failed to save lab report"
                            });
                        }

                        fs.unlink(report_file[0].path, function(err) {
                            if (err) console.error("Error deleting temp file:", err);
                        });

                        const labRecord = new Labs({
                            sequence_id: sequenceId,
                            patient_id: req.body.patient_id,
                            doctor_id: req.body.doctor_id,
                            appointment_id: req.body.appointment_id,
                            report_url: "lab_reports/" + fileName
                        });

                        labRecord.save().then((savedLab) => {
                            res.send({
                                success: true,
                                message: "Lab report saved successfully",
                                record: savedLab
                            });
                        }).catch((err) => {
                            console.error("Error saving lab record:", err);
                            res.send({
                                success: false,
                                message: "Error saving lab record",
                                error: err.message
                            });
                        });
                    });
                });
            })
            .catch(err => {
                console.error("Error checking existing lab:", err);
                res.send({
                    success: false,
                    message: "Error checking existing lab record",
                    error: err.message
                });
            });
    }



exports.patient_labs = function(req, res){
    Labs.aggregate([

        {
            $match: {
                "patient_id": ObjectId(req.body.patient_id),
                "doctor_id": ObjectId(req.body.doctor_id),
                "appointment_id": ObjectId(req.body.appointment_id),
            }
        },

        {$lookup:{
            
            from:"doctors",
            localField:"doctor_id",
            foreignField:"_id",
            as:"doctor_data"
        
            }},
            
            {$unwind:"$doctor_data"},
            
            {$lookup:{
            
            from:"patients",
            localField:"patient_id",
            foreignField:"_id",
            as:"patient_data"
        
            }},
            
            {$unwind:"$patient_data"},

            {$lookup:{
            
                from:"appointments",
                localField:"appointment_id",
                foreignField:"_id",
                as:"appointment_data"
            
                }},
                
                {$unwind:"$appointment_data"},
               
            
            
            {$project:{
                _id:1,
                doctor_name:"$doctor_data.name",
                patient_name:"$patient_data.name",
                patient_token:"$patient_data.token",
                doctor_token:"$doctor_data.token",
                patient_id:"$patient_data._id",
                doctor_id:"$doctor_data._id",
                appointment_id:"$appointment_data._id",
                patient_Gender: "$patient_data.gender",
                patient_Age: "$patient_data.age",
                doctor_phone: "$doctor_data.phone",
                patient_phone:"$patient_data.phone",
                sequence_id:1,
                report_url:1,
                status:1,
                create_date:1,
                extra_detail:1
                      
                }}
        
        ]).then((appointment_data)=>{

            if(appointment_data){

                res.send({
                    success:true,
                    message:"Successfully to fetch All labs for Patient",
                    record:appointment_data
                })
            }else{
                res.send({
                    success:false,
                    message:"Sorry! to fetch labs for Patient"
                })
    
            }


        })
        
}

exports.doctor_labs = function(req, res){
    Labs.aggregate([

        {
            $match: {
                "patient_id": ObjectId(req.body.patient_id),
                "doctor_id": ObjectId(req.body.doctor_id),
                "appointment_id": ObjectId(req.body.appointment_id),
            }
        },

        {$lookup:{
            
            from:"doctors",
            localField:"doctor_id",
            foreignField:"_id",
            as:"doctor_data"
        
            }},
            
            {$unwind:"$doctor_data"},
            
            {$lookup:{
            
            from:"patients",
            localField:"patient_id",
            foreignField:"_id",
            as:"patient_data"
        
            }},
            
            {$unwind:"$patient_data"},

            {$lookup:{
            
                from:"appointments",
                localField:"appointment_id",
                foreignField:"_id",
                as:"appointment_data"
            
                }},
                
                {$unwind:"$appointment_data"},
               
            
            
            {$project:{
                _id:1,
                doctor_name:"$doctor_data.name",
                patient_name:"$patient_data.name",
                patient_token:"$patient_data.token",
                doctor_token:"$doctor_data.token",
                patient_id:"$patient_data._id",
                doctor_id:"$doctor_data._id",
                appointment_id:"$appointment_data._id",
                patient_Gender: "$patient_data.gender",
                patient_Age: "$patient_data.age",
                doctor_phone: "$doctor_data.phone",
                patient_phone:"$patient_data.phone",
                sequence_id:1,
                report_url:1,
                status:1,
                create_date:1,
                extra_detail:1
                      
                }}
        
        ]).then((appointment_data)=>{

            if(appointment_data){

                res.send({
                    success:true,
                    message:"Successfully to fetch All labs for Patient",
                    record:appointment_data
                })
            }else{
                res.send({
                    success:false,
                    message:"Sorry! to fetch labs for Patient"
                })
    
            }


        })
        
}




// Change password API
exports.changesPassword = function(req, res) {
    const { id, PassWord, newPassword, confirmPassword } = req.body;
    
    // Check if new password matches confirm password
    if (newPassword !== confirmPassword) {
        return res.status(400).send({
            success: false,
            message: "New password and confirm password do not match"
        });
    }
    
    // Find doctor with current email and password
    Doctor.findOne({ _id: id, PassWord: PassWord }).then((doctor) => {
        if (doctor) {
            // Update doctor's password
            Doctor.findOneAndUpdate(
                { _id: id }, 
                { $set: { PassWord: newPassword } }, 
                { new: true }
            ).then((data_doctor) => {
                console.log("Doctor password updated:", data_doctor);
                res.send({
                    success: true,
                    message: "Successfully changed Doctor password",
                    record: data_doctor
                });
            }).catch((error) => {
                res.status(500).send({
                    success: false,
                    message: "Error updating doctor password"
                });
            });
        } else {
            // If not doctor, try patient
            Patient.findOne({ _id: id, PassWord: PassWord }).then((patient) => {
                if (patient) {
                    // Update patient's password
                    Patient.findOneAndUpdate(
                        { _id: id }, 
                        { $set: { PassWord: newPassword } }, 
                        { new: true }
                    ).then((data_patient) => {
                        console.log("Patient password updated:", data_patient);
                        res.send({
                            success: true,
                            message: "Successfully changed Patient password",
                            record: data_patient
                        });
                    }).catch((error) => {
                        res.status(500).send({
                            success: false,
                            message: "Error updating patient password"
                        });
                    });
                } else {
                    res.send({
                        success: false,
                        message: "Invalid Email or Password"
                    });
                }
            }).catch((error) => {
                res.status(500).send({
                    success: false,
                    message: "Error finding patient"
                });
            });
        }
    }).catch((error) => {
        res.status(500).send({
            success: false,
            message: "Error finding doctor"
        });
    });
};

// lab request 

exports.save_LabRequest = function(req, res) {
    try {
        // Validate required fields
        if (!req.body.requested_tests || !Array.isArray(req.body.requested_tests)) {
            return res.status(400).send({
                success: false,
                message: "Requested tests array is required"
            });
        }
        // Validate each test in the array
        const testsValidation = req.body.requested_tests.every(test => {
            return test.test_name && test.description && test.priority;
        });

        if (!testsValidation) {
            return res.status(400).send({
                success: false,
                message: "Each test must have name, description and priority"
            });
        }
        

        // Create the lab request
        const LabRequest = new labRequest({
            requested_tests: req.body.requested_tests.map(test => ({
                test_name: test.test_name,
                description: test.description,
                priority: test.priority
            })),
            sequence_id: Utils.get_unique_id(),
            patient_id: req.body.patient_id,
            doctor_id: req.body.doctor_id,
            appointment_id: req.body.appointment_id,
            notes: req.body.notes
        });

     

        // First get patient and doctor details
        Promise.all([
            Patient.findById(req.body.patient_id),
            Doctor.findById(req.body.doctor_id)
        ])
        .then(([patient, doctor]) => {
            if (!patient) {
                throw new Error('Patient not found');
            }
            if (!doctor) {
                throw new Error('Doctor not found');
            }

            // Save prescription
            return LabRequest.save().then(savedPrescription => {
    
                return res.status(201).send({
                    success: true,
                    message: "labRequest registered successfully",
                    record: savedPrescription
                });
            });
        })
        .catch(err => {
            console.error("Save error:", err);
            res.status(500).send({
                success: false,
                message: "Failed to save labRequest",
                error: err.message
            });
        });
    } catch (err) {
        console.error("Unexpected error:", err);
        res.status(500).send({
            success: false,
            message: "Internal server error",
            error: err.message
        });
    }
};


exports.patient_LabRequest = function(req, res){
    labRequest.aggregate([

        {
           $match: {
                "patient_id": ObjectId(req.body.patient_id),
                "doctor_id": ObjectId(req.body.doctor_id),
                "appointment_id": ObjectId(req.body.appointment_id),
            }
        },
        {$lookup:{
            from:"doctors",
            localField:"doctor_id",
            foreignField:"_id",
            as:"doctor_data"
        }},
        
        {$unwind:"$doctor_data"},
        
        {$lookup:{
            from:"patients",
            localField:"patient_id",
            foreignField:"_id",
            as:"patient_data"
        }},
        
        {$unwind:"$patient_data"},

        {$lookup:{
            from:"appointments",
            localField:"appointment_id",
            foreignField:"_id",
            as:"appointment_data"
        }},
        
        {$unwind:"$appointment_data"},

        {$lookup:{
            from:"shifts",
            localField:"appointment_data.shifts_id",
            foreignField:"_id",
            as:"shifts_data"
        }},
        
        {$unwind:"$shifts_data"},
        
        {$project:{
            _id:1,
            requested_tests: 1,
            doctor_name:"$doctor_data.name",
            patient_name:"$patient_data.name",
            patient_token:"$patient_data.token",
            doctor_token:"$doctor_data.token",
            patient_id:"$patient_data._id",
            doctor_id:"$doctor_data._id",
            appointment_id:"$appointment_data._id",
            patient_phone:"$patient_data.phone",
            doctor_phone:"$doctor_data.phone",
            patient_profile:"$patient_data.picture",
            patient_Gender: "$patient_data.gender",
            patient_Age: "$patient_data.age",
             shift_time:"$shifts_data.time",
             shift_day:"$shifts_data.day",
            sequence_id:1,
            priority:1,
            description:1,
            test_name:1,
            create_date:1, 
            notes:1         
        }}
        
    ]).then((labRequest_data)=>{
        console.log("dataaaa",labRequest_data)
        if(labRequest_data){
            res.send({
                success:true,
                message:"Successfully to fetch All Appointements for Doctor",
                record:labRequest_data
            })
        }else{
            res.send({
                success:false,
                message:"Sorry! to fetch Appointements for Doctor"
            })
        }
    })
}

exports.doctor_LabRequest = function(req, res){
    labRequest.aggregate([

        {
           $match: {
                "patient_id": ObjectId(req.body.patient_id),
                "doctor_id": ObjectId(req.body.doctor_id),
                "appointment_id": ObjectId(req.body.appointment_id),
            }
        },
        {$lookup:{
            from:"doctors",
            localField:"doctor_id",
            foreignField:"_id",
            as:"doctor_data"
        }},
        
        {$unwind:"$doctor_data"},
        
        {$lookup:{
            from:"patients",
            localField:"patient_id",
            foreignField:"_id",
            as:"patient_data"
        }},
        
        {$unwind:"$patient_data"},

        {$lookup:{
            from:"appointments",
            localField:"appointment_id",
            foreignField:"_id",
            as:"appointment_data"
        }},
        
        {$unwind:"$appointment_data"},

        {$lookup:{
            from:"shifts",
            localField:"appointment_data.shifts_id",
            foreignField:"_id",
            as:"shifts_data"
        }},
        
        {$unwind:"$shifts_data"},
        
        {$project:{
            _id:1,
            requested_tests: 1,
            doctor_name:"$doctor_data.name",
            patient_name:"$patient_data.name",
            patient_token:"$patient_data.token",
            doctor_token:"$doctor_data.token",
            patient_id:"$patient_data._id",
            doctor_id:"$doctor_data._id",
            appointment_id:"$appointment_data._id",
            patient_phone:"$patient_data.phone",
            doctor_phone:"$doctor_data.phone",
            patient_profile:"$patient_data.picture",
            patient_Gender: "$patient_data.gender",
            patient_Age: "$patient_data.age",
             shift_time:"$shifts_data.time",
             shift_day:"$shifts_data.day",
            sequence_id:1,
            priority:1,
            description:1,
            test_name:1,
            create_date:1,
            notes:1          
        }}
        
    ]).then((labRequest_data)=>{
        console.log("dataaaa",labRequest_data)
        if(labRequest_data){
            res.send({
                success:true,
                message:"Successfully to fetch All Appointements for Doctor",
                record:labRequest_data
            })
        }else{
            res.send({
                success:false,
                message:"Sorry! to fetch Appointements for Doctor"
            })
        }
    })
}


/// forget password 


exports.forget_Password = async function (req, res) {
    const email = req.body.email;
    if (!email) {
        return res.send({
            success: false,
            message: "Email is required."
        });
    }

    // Try to find patient first
    let user = await Patient.findOne({ email: email });
    let userType = 'patient';

    if (!user) {
        // If not found as patient, check doctor
        user = await Doctor.findOne({ email: email });
        userType = 'doctor';
    }

    if (!user) {
        return res.send({
            success: false,
            message: "No user found with this email."
        });
    }

    // Generate OTP
    // const otp = utils.get_otp_number(6);
    const otp = Utils.get_otp_number(6)

    // Save OTP to user (add a field if not present)
    user.reset_otp = otp;
    user.reset_otp_expiry = Date.now() + 10 * 60 * 1000; // 10 minutes expiry
    await user.save();

    // Send OTP via email
    const msg = `Your password reset OTP is: ${otp}`;
    Utils.send_email_otp(req, email, msg);

    res.send({
        success: true,
        message: `Password reset OTP sent to ${userType} email.`
    });
};


// verify Otp

exports.VerifyOtp = async function (req, res) {
    const { email, otp } = req.body;
    console.log("email", email, "otp", otp);
    if (!email || !otp) {
        return res.send({
            success: false,
            message: "Email and OTP are required."
        });
    }

    // Try to find patient first
    let user = await Patient.findOne({ email: email });
    let userType = 'patient';

    if (!user) {
        // If not found as patient, check doctor
        user = await Doctor.findOne({ email: email });
        userType = 'doctor';
    }

    if (!user) {
        return res.send({
            success: false,
            message: "No user found with this email."
        });
    }
    console.log("user", user);
    // Make sure OTP is string for comparison
    const userOtp = user.reset_otp ? user.reset_otp.toString() : "";
    const inputOtp = otp.toString();

    // Check OTP and expiry
    if (
        userOtp !== inputOtp ||
        !user.reset_otp_expiry ||
        user.reset_otp_expiry < Date.now()
    ) {
        return res.send({
            success: false,
            message: "Invalid or expired OTP."
        });
    }

    // OTP is valid, clear it
    user.reset_otp = undefined;
    user.reset_otp_expiry = undefined;
    await user.save();

    res.send({
        success: true,
        message: "OTP verified successfully. You can now reset your password.",
        userType: userType,
        userId: user._id
    });
}

 
// Reset password after OTP verification
exports.resetPassword = async function (req, res) {
    const { email, newPassword, confirmPassword } = req.body;

    if (!email || !newPassword || !confirmPassword) {
        return res.send({
            success: false,
            message: "Email, new password, and confirm password are required."
        });
    }

    if (newPassword !== confirmPassword) {
        return res.send({
            success: false,
            message: "New password and confirm password do not match."
        });
    }

    // Try to find patient first
    let user = await Patient.findOne({ email: email });
    let userType = 'patient';

    if (!user) {
        // If not found as patient, check doctor
        user = await Doctor.findOne({ email: email });
        userType = 'doctor';
    }

    if (!user) {
        return res.send({
            success: false,
            message: "No user found with this email."
        });
    }

    // Update password (both PassWord and hashed password)
    user.PassWord = newPassword;
    user.password = bcrypt.hashSync(newPassword, 10);

    // Clear OTP fields if present
    user.reset_otp = undefined;
    user.reset_otp_expiry = undefined;

    await user.save();

    res.send({
        success: true,
        message: "Password reset successfully.",
        userType: userType,
        userId: user._id
    });
}


///patient_notification

exports.patient_notification = function(req, res){
        Message.aggregate([

            {
                $match: {
                    "patient_id": ObjectId(req.body.patient_id)
                }
            },
                
                {$lookup:{
                
                from:"patients",
                localField:"patient_id",
                foreignField:"_id",
                as:"patient_data"
            
                }},
                
                {$unwind:"$patient_data"},
                
                
                {$project:{
                    _id:1,
                    patient_name:"$patient_data.name",
                    patient_token:"$patient_data.token",
                    patient_id:"$patient_data._id",
                    patient_phone:"$patient_data.phone",
                    patient_profile:"$patient_data.picture",
                    patient_Gender: "$patient_data.gender",
                    patient_Age: "$patient_data.age",
                    sequence_id:1,
                    title: 1,
                    message :1,
                    status:1,
                    create_date:1
                          
                    }}
            
            ]).then((message_data)=>{

                if(message_data){

                    res.send({
                        success:true,
                        message:"Successfully to fetch All Appointements for Patient",
                        record:message_data
                    })
                }else{
                    res.send({
                        success:false,
                        message:"Sorry! to fetch Appointements for Patient"
                    })
        
                }


            })
            
}

exports.doctor_notification = function(req, res){
        Message.aggregate([

            {
                $match: {
                    "doctor_id": ObjectId(req.body.doctor_id)
                }
            },

            {$lookup:{
                
                from:"doctors",
                localField:"doctor_id",
                foreignField:"_id",
                as:"doctor_data"
            
                }},
                
                {$unwind:"$doctor_data"},
                
                
                
                {$project:{
                    _id:1,
                    doctor_name:"$doctor_data.name",
                    doctor_profile:"$doctor_data.picture",
                    doctor_token:"$doctor_data.token",
                    doctor_phone:"$doctor_data.phone",
                    doctor_id:"$doctor_data._id",
                    sequence_id:1,
                    title: 1,
                    message :1,
                    status:1,
                    create_date:1
                          
                    }}
            
            ]).then((message_data)=>{

                if(message_data){

                    res.send({
                        success:true,
                        message:"Successfully to fetch All Appointements for Patient",
                        record:message_data
                    })
                }else{
                    res.send({
                        success:false,
                        message:"Sorry! to fetch Appointements for Patient"
                    })
        
                }


            })
            
}


exports.save_message = function (req, res) {
        console.log("Request body:", req.body);
        const message = new Message({
            title: req.body.title,
            message: req.body.message,
            sequence_id: Utils.get_unique_id(),
            patient_id: req.body.patient_id,  // Optional
            doctor_id: req.body.doctor_id,   // Optional
        });
        message.save()
            .then((messageData) => {
                res.send({
                    success: true,
                     data: messageData,
                })
            })
            .catch(error => {
                console.error("Error saving message:", error);
            });
        }
exports.allAppointments = function(req, res) {
    Appointment.aggregate([
        {
            $lookup: {
                from: "doctors",
                localField: "doctor_id",
                foreignField: "_id",
                as: "doctor_data"
            }
        },
        { $unwind: "$doctor_data" },
        {
            $lookup: {
                from: "patients",
                localField: "patient_id",
                foreignField: "_id",
                as: "patient_data"
            }
        },
        { $unwind: "$patient_data" },
        {
            $lookup: {
                from: "shifts",
                localField: "shifts_id",
                foreignField: "_id",
                as: "shifts_data"
            }
        },
        { $unwind: "$shifts_data" },
        {
            $project: {
                _id: 1,
                doctor_name: "$doctor_data.name",
                doctor_profile: "$doctor_data.picture",
                patient_name: "$patient_data.name",
                patient_token: "$patient_data.token",
                doctor_token: "$doctor_data.token",
                patient_id: "$patient_data._id",
                patient_phone: "$patient_data.phone",
                doctor_phone: "$doctor_data.phone",
                doctor_id: "$doctor_data._id",
                shift_time: "$shifts_data.time",
                shift_day: "$shifts_data.day",
                shift_id: "$shifts_data._id",
                patient_Gender: "$patient_data.gender",
                patient_Age: "$patient_data.age",
                sequence_id: 1,
                appointment_date: 1,
                is_reviewed: 1,
                status: 1,
                create_date: 1
            }
        }
    ]).then((appointments) => {
        console.log("Appointments fetched:", appointments);
        if (appointments.length > 0) {
            res.send({
                success: true,
                message: "Successfully fetched all appointments.",
                record: appointments
            });
        } else {
            res.send({
                success: false,
                message: "No appointments found."
            });
        }
    }).catch((err) => {
        console.error("Error fetching appointments:", err);
        res.status(500).send({
            success: false,
            message: "Error fetching appointments.",
            error: err.message
        });
    });
};
// Relay push notifications from the app (calls, appointments, lab requests) to FCM.
exports.send_push = async function (req, res) {
  const message = req.body.message;
  if (!message || typeof message !== 'object') {
    return res.status(400).send({ success: false, message: 'message is required' });
  }
  const type = message.data && message.data.type ? message.data.type : 'notification';
  // Apps only ever hold sealed tokens: open it here
  if (message.token) message.token = Utils.unsealToken(message.token);

  // Optional { to: { type: 'patient'|'doctor', id } }: use that person's *current* device token
  const to = req.body.to;
  let who = 'device';
  if (to && (to.type === 'patient' || to.type === 'doctor') && /^[a-f0-9]{24}$/i.test(String(to.id || ''))) {
    const Model = to.type === 'patient' ? Patient : Doctor;
    const person = await Model.findById(to.id, { token: 1, name: 1 });
    if (!person) return res.status(404).send({ success: false, message: `This ${to.type} no longer exists` });
    who = `${to.type} "${person.name}"`;
    if (person.token) message.token = person.token;
  }
  if (!message.token) {
    console.warn(`send_push [${type}] to ${who}: no device token`);
    return res.status(409).send({
      success: false,
      message: `The ${to && to.type ? to.type : 'other person'}'s phone is not registered for notifications yet. ` +
        'They need to open the app (logged in) on a phone where Google Play services works, then try again.',
    });
  }
  // FCM only accepts string values inside `data`
  if (message.data) {
    for (const key of Object.keys(message.data)) message.data[key] = String(message.data[key] ?? '');
  }
  try {
    const result = await Utils.send_fcm_message(message);
    console.log(`send_push [${type}] to ${who}: delivered to Firebase`);
    res.send({ success: true, record: result });
  } catch (err) {
    const fcmError = err.response?.data?.error;
    console.error(`send_push [${type}] to ${who} failed:`, fcmError?.message || err.message);
    // Token from an old install / old Firebase project: forget it and explain
    const dead = /NotRegistered|UNREGISTERED|not a valid FCM registration token|SenderId mismatch/i.test(
      `${fcmError?.status || ''} ${fcmError?.message || ''} ${JSON.stringify(fcmError?.details || [])}`);
    if (dead) {
      if (to && /^[a-f0-9]{24}$/i.test(String(to.id || ''))) {
        const Model = to.type === 'patient' ? Patient : Doctor;
        await Model.updateOne({ _id: to.id, token: message.token }, { $set: { token: '' } }).catch(() => {});
      }
      return res.status(410).send({
        success: false,
        message: `The ${to && to.type ? to.type : 'other person'}'s phone has an outdated registration (old app version or reinstalled app). ` +
          'They need to open the latest app and log in again, then try again.',
      });
    }
    res.status(fcmError?.code || 500).send({ success: false, message: fcmError?.message || err.message });
  }
};


// ---------------- Call sessions ----------------
// Every call is tracked on the server so both phones can see what happened
// (accepted / declined / cancelled / missed) even if a push notification is lost
// or the phone has no Google Play services.
const CALL_FINAL = ['declined', 'cancelled', 'missed', 'ended'];

// POST /call_start { roomId, doctor_id, patient_id, call_type, caller_type }
exports.call_start = async function (req, res) {
  try {
    const { roomId, doctor_id, patient_id, call_type, caller_type } = req.body;
    if (!roomId) return res.status(400).send({ success: false, message: 'roomId is required' });
    const record = await Conseltaion.findOneAndUpdate(
      { roomID: roomId },
      {
        $set: { status: 'ringing', doctor_id, patient_id, call_type: String(call_type ?? '0'), caller_type: caller_type || 'doctor', update_date: new Date() },
        $setOnInsert: { sequence_id: Utils.get_unique_id(), roomID: roomId, create_date: new Date() },
      },
      { upsert: true, new: true }
    );
    res.send({ success: true, status: record.status });
  } catch (err) {
    console.error('call_start:', err.message);
    res.status(500).send({ success: false, message: 'Could not start the call' });
  }
};

// POST /call_update { roomId, status: answered|declined|cancelled|missed|ended }
exports.call_update = async function (req, res) {
  try {
    const { roomId, status } = req.body;
    if (!roomId || !['answered', ...CALL_FINAL].includes(status)) {
      return res.status(400).send({ success: false, message: 'roomId and a valid status are required' });
    }
    const call = await Conseltaion.findOne({ roomID: roomId });
    if (!call) return res.status(404).send({ success: false, message: 'Call not found' });
    // A finished call stays finished (e.g. a late "answered" after "cancelled")
    if (CALL_FINAL.includes(call.status) && status !== 'ended') {
      return res.send({ success: true, status: call.status });
    }
    call.status = status;
    call.update_date = new Date();
    await call.save();
    console.log(`call ${roomId}: ${status}`);
    res.send({ success: true, status });
  } catch (err) {
    console.error('call_update:', err.message);
    res.status(500).send({ success: false, message: 'Could not update the call' });
  }
};

// POST /call_status { roomId } -> { status }
exports.call_status = async function (req, res) {
  try {
    const call = await Conseltaion.findOne({ roomID: req.body.roomId }, { status: 1, update_date: 1, create_date: 1 });
    if (!call) return res.send({ success: true, status: 'unknown' });
    // Nobody answered within 60 s: treat as missed
    const age = Date.now() - new Date(call.update_date || call.create_date).getTime();
    if (call.status === 'ringing' && age > 60000) {
      call.status = 'missed';
      await call.save();
    }
    res.send({ success: true, status: call.status });
  } catch (err) {
    res.status(500).send({ success: false, message: 'Could not read the call' });
  }
};

// POST /call_incoming { user_id, user_type: 'patient'|'doctor' }
// Lets an open app find a call ringing for it even when push notifications
// don't work on that phone (e.g. no Google Play services).
exports.call_incoming = async function (req, res) {
  try {
    const { user_id, user_type } = req.body;
    if (!/^[a-f0-9]{24}$/i.test(String(user_id || '')) || !['patient', 'doctor'].includes(user_type)) {
      return res.status(400).send({ success: false, message: 'user_id and user_type are required' });
    }
    const since = new Date(Date.now() - 45000);
    const callerType = user_type === 'patient' ? 'doctor' : 'patient';
    const call = await Conseltaion.findOne({
      [`${user_type}_id`]: user_id,
      caller_type: callerType,
      status: 'ringing',
      $or: [{ update_date: { $gte: since } }, { create_date: { $gte: since } }],
    }).sort({ create_date: -1 });
    if (!call) return res.send({ success: true, call: null });

    const Caller = callerType === 'doctor' ? Doctor : Patient;
    const caller = await Caller.findById(call[`${callerType}_id`], { name: 1, picture: 1, phone: 1 });
    res.send({
      success: true,
      call: {
        type: 'call_invitation',
        roomId: call.roomID,
        callType: call.call_type || '0',
        callerType,
        callerName: caller ? caller.name : '',
        picture: caller ? caller.picture || '' : '',
        callerPhone: caller ? caller.phone || '' : '',
        doctor_id: String(call.doctor_id || ''),
        patient_id: String(call.patient_id || ''),
      },
    });
  } catch (err) {
    res.status(500).send({ success: false, message: 'Could not check for calls' });
  }
};
