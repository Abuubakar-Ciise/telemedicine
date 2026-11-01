// Dashboard overview, reports and admin messages.
const mongoose = require('mongoose');
const Utils = require('../controller/utils');
const { isObjectId, toObjectId } = require('./helpers');

const M = (name) => mongoose.model(name);

function dateRange(query, days = 30) {
  const to = query.to ? new Date(query.to) : new Date();
  to.setHours(23, 59, 59, 999);
  const from = query.from ? new Date(query.from) : new Date(to.getTime() - (days - 1) * 86400000);
  from.setHours(0, 0, 0, 0);
  return { from, to };
}

// GET /admin/api/stats/overview
exports.overview = async function (req, res, next) {
  try {
    const { from, to } = dateRange(req.query, 30);
    const inRange = { create_date: { $gte: from, $lte: to } };

    const [
      doctors, activeDoctors, patients, hospitals, specialities, appointments,
      appointmentsByStatus, revenue, appointmentsPerDay, revenuePerDay, topDoctors,
      bySpeciality, recentAppointments, ratingAgg, pendingLabRequests,
    ] = await Promise.all([
      M('doctor').countDocuments(),
      M('doctor').countDocuments({ status: 1 }),
      M('patient').countDocuments(),
      M('hospital').countDocuments(),
      M('speciality').countDocuments(),
      M('appointment').countDocuments(),
      M('appointment').aggregate([{ $group: { _id: '$status', count: { $sum: 1 } } }]),
      M('payment').aggregate([{ $match: { status: 1 } }, { $group: { _id: null, total: { $sum: '$amount' }, count: { $sum: 1 } } }]),
      M('appointment').aggregate([
        { $match: inRange },
        { $group: { _id: { $dateToString: { format: '%Y-%m-%d', date: '$create_date', timezone: 'Africa/Mogadishu' } }, count: { $sum: 1 } } },
        { $sort: { _id: 1 } },
      ]),
      M('payment').aggregate([
        { $match: { ...inRange, status: 1 } },
        { $group: { _id: { $dateToString: { format: '%Y-%m-%d', date: '$create_date', timezone: 'Africa/Mogadishu' } }, total: { $sum: '$amount' } } },
        { $sort: { _id: 1 } },
      ]),
      M('appointment').aggregate([
        { $group: { _id: '$doctor_id', count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 5 },
        { $lookup: { from: 'doctors', localField: '_id', foreignField: '_id', as: 'doctor' } },
        { $unwind: '$doctor' },
        { $project: { _id: 1, count: 1, name: '$doctor.name', picture: '$doctor.picture', rating: '$doctor.rating' } },
      ]),
      M('doctor').aggregate([
        { $group: { _id: '$speciality_id', count: { $sum: 1 } } },
        { $lookup: { from: 'specialities', localField: '_id', foreignField: '_id', as: 's' } },
        { $unwind: { path: '$s', preserveNullAndEmptyArrays: true } },
        { $project: { _id: 0, name: { $ifNull: ['$s.name', 'Unassigned'] }, count: 1 } },
        { $sort: { count: -1 } },
      ]),
      M('appointment').aggregate([
        { $sort: { create_date: -1 } },
        { $limit: 6 },
        { $lookup: { from: 'doctors', localField: 'doctor_id', foreignField: '_id', as: 'd' } },
        { $lookup: { from: 'patients', localField: 'patient_id', foreignField: '_id', as: 'p' } },
        { $project: { sequence_id: 1, appointment_date: 1, status: 1, create_date: 1,
          doctor_name: { $first: '$d.name' }, patient_name: { $first: '$p.name' } } },
      ]),
      M('feedback').aggregate([{ $group: { _id: null, avg: { $avg: '$rating' }, count: { $sum: 1 } } }]),
      M('labRequest').countDocuments({ status: { $in: [null, '', 'pending', 'Pending'] } }),
    ]);

    // Fill missing days with 0 so charts have a continuous axis
    const days = [];
    const apptMap = Object.fromEntries(appointmentsPerDay.map((d) => [d._id, d.count]));
    const revMap = Object.fromEntries(revenuePerDay.map((d) => [d._id, d.total]));
    for (let t = from.getTime(); t <= to.getTime(); t += 86400000) {
      const key = new Date(t).toLocaleDateString('en-CA', { timeZone: 'Africa/Mogadishu' });
      if (!days.find((d) => d.date === key)) days.push({ date: key, appointments: apptMap[key] || 0, revenue: revMap[key] || 0 });
    }

    res.send({
      success: true,
      totals: {
        doctors, activeDoctors, patients, hospitals, specialities, appointments,
        revenue: revenue[0]?.total || 0,
        payments: revenue[0]?.count || 0,
        averageRating: ratingAgg[0] ? Number(ratingAgg[0].avg.toFixed(2)) : 0,
        feedbackCount: ratingAgg[0]?.count || 0,
        pendingLabRequests,
      },
      appointmentsByStatus: appointmentsByStatus.map((s) => ({ status: s._id, count: s.count })),
      daily: days,
      topDoctors,
      bySpeciality,
      recentAppointments,
    });
  } catch (err) {
    next(err);
  }
};

// GET /admin/api/stats/reports?from=&to=
exports.reports = async function (req, res, next) {
  try {
    const { from, to } = dateRange(req.query, 30);
    const inRange = { create_date: { $gte: from, $lte: to } };

    const [byDoctor, byHospital, paymentsByStatus, appointmentsByStatus, feedbackByDoctor] = await Promise.all([
      M('appointment').aggregate([
        { $match: inRange },
        { $group: {
          _id: '$doctor_id',
          appointments: { $sum: 1 },
          completed: { $sum: { $cond: [{ $eq: ['$status', 2] }, 1, 0] } },
          cancelled: { $sum: { $cond: [{ $eq: ['$status', 3] }, 1, 0] } },
        } },
        { $lookup: { from: 'payments', let: { d: '$_id' }, as: 'pay', pipeline: [
          { $match: { $expr: { $eq: ['$doctor_id', '$$d'] }, status: 1, ...inRange } },
          { $group: { _id: null, total: { $sum: '$amount' } } },
        ] } },
        { $lookup: { from: 'doctors', localField: '_id', foreignField: '_id', as: 'doc' } },
        { $lookup: { from: 'hospitals', localField: 'doc.hospital_id', foreignField: '_id', as: 'hos' } },
        { $project: { _id: 1, appointments: 1, completed: 1, cancelled: 1,
          revenue: { $ifNull: [{ $first: '$pay.total' }, 0] },
          name: { $ifNull: [{ $first: '$doc.name' }, 'Deleted doctor'] },
          hospital: { $first: '$hos.name' } } },
        { $sort: { appointments: -1 } },
      ]),
      M('payment').aggregate([
        { $match: { ...inRange, status: 1 } },
        { $lookup: { from: 'doctors', localField: 'doctor_id', foreignField: '_id', as: 'doc' } },
        { $lookup: { from: 'hospitals', localField: 'doc.hospital_id', foreignField: '_id', as: 'hos' } },
        { $group: { _id: { $first: '$hos._id' }, name: { $first: { $first: '$hos.name' } }, revenue: { $sum: '$amount' }, payments: { $sum: 1 } } },
        { $project: { _id: 1, name: { $ifNull: ['$name', 'Unknown'] }, revenue: 1, payments: 1 } },
        { $sort: { revenue: -1 } },
      ]),
      M('payment').aggregate([{ $match: inRange }, { $group: { _id: '$status', count: { $sum: 1 }, total: { $sum: '$amount' } } }]),
      M('appointment').aggregate([{ $match: inRange }, { $group: { _id: '$status', count: { $sum: 1 } } }]),
      M('feedback').aggregate([
        { $match: inRange },
        { $group: { _id: '$doctor_id', avg: { $avg: '$rating' }, count: { $sum: 1 } } },
        { $lookup: { from: 'doctors', localField: '_id', foreignField: '_id', as: 'doc' } },
        { $project: { _id: 1, avg: { $round: ['$avg', 2] }, count: 1, name: { $ifNull: [{ $first: '$doc.name' }, 'Deleted doctor'] } } },
        { $sort: { avg: -1 } },
      ]),
    ]);

    res.send({
      success: true,
      from, to,
      byDoctor, byHospital, feedbackByDoctor,
      paymentsByStatus: paymentsByStatus.map((s) => ({ status: s._id, count: s.count, total: s.total })),
      appointmentsByStatus: appointmentsByStatus.map((s) => ({ status: s._id, count: s.count })),
    });
  } catch (err) {
    next(err);
  }
};

// POST /admin/api/messages/send
// { target: 'patient'|'doctor'|'all_patients'|'all_doctors', recipient_id?, title, message }
exports.sendMessage = async function (req, res, next) {
  try {
    const { target, recipient_id, title, message } = req.body;
    if (!title || !message) return res.status(400).send({ success: false, message: 'Title and message are required' });

    let recipients = [];
    if (target === 'patient' || target === 'doctor') {
      if (!isObjectId(recipient_id)) return res.status(400).send({ success: false, message: 'Choose a recipient' });
      const doc = await M(target).findById(recipient_id, { token: 1 });
      if (!doc) return res.status(404).send({ success: false, message: 'Recipient not found' });
      recipients = [{ type: target, doc }];
    } else if (target === 'all_patients' || target === 'all_doctors') {
      const type = target === 'all_patients' ? 'patient' : 'doctor';
      recipients = (await M(type).find({ status: 1 }, { token: 1 })).map((doc) => ({ type, doc }));
    } else {
      return res.status(400).send({ success: false, message: 'Invalid target' });
    }

    const Message = M('message');
    let pushed = 0;
    for (const { type, doc } of recipients) {
      await Message.create({
        sequence_id: Utils.get_unique_id(),
        title,
        message,
        token: doc.token,
        [`${type}_id`]: doc._id,
      });
      if (doc.token) {
        await new Promise((resolve) =>
          Utils.send_notification({ token: doc.token, title, message, dataPayload: { type: 'admin_message', title, body: message } },
            (err) => { if (!err) pushed++; resolve(); })
        );
      }
    }

    res.send({ success: true, message: `Saved for ${recipients.length} recipient(s), ${pushed} push notification(s) delivered`, saved: recipients.length, pushed });
  } catch (err) {
    next(err);
  }
};
