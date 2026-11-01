// Generic list / get / create / update / delete handlers driven by resources.js
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const resources = require('./resources');
const { saveUpload, deleteUpload, validatePassword, isObjectId, toObjectId, escapeRegex } = require('./helpers');

const HIDDEN = { password: 0, PassWord: 0, token: 0, reset_otp: 0, reset_otp_expiry: 0, __v: 0 };

function getResource(req, res) {
  const config = resources[req.params.resource];
  if (!config) {
    res.status(404).send({ success: false, message: `Unknown section "${req.params.resource}"` });
    return null;
  }
  return config;
}

function lookupStages(config) {
  const stages = [];
  const project = {};
  for (const l of config.lookups || []) {
    stages.push(
      { $lookup: { from: l.from, localField: l.localField, foreignField: '_id', as: l.as } },
      { $unwind: { path: `$${l.as}`, preserveNullAndEmptyArrays: true } }
    );
    project[`${l.as}_name`] = `$${l.as}.${l.nameField || 'name'}`;
    if (l.as === 'doctor' || l.as === 'patient') project[`${l.as}_phone`] = `$${l.as}.phone`;
  }
  Object.assign(project, config.extraProject || {});
  if (Object.keys(project).length) stages.push({ $addFields: project });
  const drop = { ...HIDDEN };
  for (const l of config.lookups || []) drop[l.as] = 0;
  stages.push({ $project: drop });
  return stages;
}

function castValue(config, key, value) {
  if (value === '' || value === undefined) return value;
  if ((config.numbers || []).includes(key)) return Number(value);
  if (key.endsWith('_id') && isObjectId(value)) return toObjectId(value);
  if (value === 'true') return true;
  if (value === 'false') return false;
  return value;
}

function buildMatch(config, query) {
  const match = {};
  for (const key of config.filters || []) {
    const v = query[key];
    if (v === undefined || v === '' || v === 'ALL') continue;
    match[key] = castValue(config, key, v);
  }
  if (query.from || query.to) {
    match.create_date = {};
    if (query.from) match.create_date.$gte = new Date(query.from);
    if (query.to) {
      const to = new Date(query.to);
      to.setHours(23, 59, 59, 999);
      match.create_date.$lte = to;
    }
  }
  return match;
}

// GET /admin/api/:resource?page=1&limit=20&search=&sort=-create_date&<filters>&from=&to=
exports.list = async function (req, res, next) {
  const config = getResource(req, res);
  if (!config) return;
  try {
    const Model = mongoose.model(config.model);
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(5000, Math.max(1, parseInt(req.query.limit) || 20));
    const sortKey = String(req.query.sort || '-create_date');
    const sort = { [sortKey.replace(/^-/, '')]: sortKey.startsWith('-') ? -1 : 1, _id: -1 };

    const pipeline = [{ $match: buildMatch(config, req.query) }, ...lookupStages(config)];
    const search = String(req.query.search || '').trim();
    if (search && config.search) {
      const rx = new RegExp(escapeRegex(search), 'i');
      pipeline.push({ $match: { $or: config.search.map((f) => ({ [f]: rx })) } });
    }
    pipeline.push({
      $facet: {
        items: [{ $sort: sort }, { $skip: (page - 1) * limit }, { $limit: limit }],
        total: [{ $count: 'count' }],
      },
    });

    const [result] = await Model.aggregate(pipeline);
    const total = result.total[0]?.count || 0;
    res.send({ success: true, items: result.items, total, page, limit, pages: Math.ceil(total / limit) });
  } catch (err) {
    next(err);
  }
};

// GET /admin/api/:resource/options?doctor_id=  -> [{ value, label }]
exports.options = async function (req, res, next) {
  const config = getResource(req, res);
  if (!config) return;
  try {
    const Model = mongoose.model(config.model);
    const labelField = config.label || 'sequence_id';
    const match = buildMatch(config, req.query);
    const docs = await Model.find(match, { [labelField]: 1, day: 1, phone: 1 }).sort({ [labelField]: 1 }).limit(2000).lean();
    res.send({
      success: true,
      items: docs.map((d) => ({
        value: d._id,
        label: d.day ? `${d.day} ${d[labelField]}` : d.phone && ['doctor', 'patient'].includes(config.model) ? `${d[labelField]} (${d.phone})` : d[labelField],
      })),
    });
  } catch (err) {
    next(err);
  }
};

// GET /admin/api/:resource/:id
exports.get = async function (req, res, next) {
  const config = getResource(req, res);
  if (!config) return;
  if (!isObjectId(req.params.id)) return res.status(400).send({ success: false, message: 'Invalid id' });
  try {
    const Model = mongoose.model(config.model);
    const [item] = await Model.aggregate([{ $match: { _id: toObjectId(req.params.id) } }, ...lookupStages(config)]);
    if (!item) return res.status(404).send({ success: false, message: 'Not found' });
    res.send({ success: true, item });
  } catch (err) {
    next(err);
  }
};

function collectData(config, req, isCreate) {
  const data = {};
  for (const key of config.fields || []) {
    if (req.body[key] === undefined) continue;
    let v = castValue(config, key, req.body[key]);
    if (v === '' && (key.endsWith('_id') || (config.numbers || []).includes(key))) v = null;
    data[key] = v;
  }
  if (config.transform) config.transform(data, { isCreate });

  if (config.password && req.body.password) {
    const problem = validatePassword(req.body.password);
    if (problem) throw Object.assign(new Error(problem), { status: 400 });
    data.password = bcrypt.hashSync(String(req.body.password), 10);
    // The mobile app logs doctors/patients in with the plain "PassWord" field.
    if (config.passwordForApp) data.PassWord = String(req.body.password);
  }
  if (config.image) {
    const picture = saveUpload(req, 'picture');
    if (picture) data.picture = picture;
  }
  return data;
}

function friendlyError(err) {
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue || {})[0] || 'value';
    return { status: 409, message: `A record with this ${field} already exists` };
  }
  if (err.name === 'ValidationError') {
    return { status: 400, message: Object.values(err.errors).map((e) => e.message).join(', ') };
  }
  if (err.status) return { status: err.status, message: err.message };
  return null;
}

// POST /admin/api/:resource
exports.create = async function (req, res, next) {
  const config = getResource(req, res);
  if (!config) return;
  if (config.readOnly || config.create === false) {
    return res.status(405).send({ success: false, message: 'Creating is not allowed for this section' });
  }
  try {
    const Model = mongoose.model(config.model);
    if (config.password && !req.body.password) {
      return res.status(400).send({ success: false, message: 'Password is required' });
    }
    const data = { ...(config.defaults ? config.defaults() : {}), ...collectData(config, req, true) };

    if (config.multiCreate) {
      let list = req.body[config.multiCreate];
      if (typeof list === 'string') list = list.split(',');
      list = (list || []).filter(Boolean);
      if (!list.length) return res.status(400).send({ success: false, message: 'Select at least one day' });
      const docs = await Model.insertMany(list.map((day) => ({ ...data, day })));
      return res.status(201).send({ success: true, items: docs, message: `${docs.length} created` });
    }

    const doc = await Model.create(data);
    res.status(201).send({ success: true, item: doc, message: 'Created' });
  } catch (err) {
    const e = friendlyError(err);
    if (e) return res.status(e.status).send({ success: false, message: e.message });
    next(err);
  }
};

// PUT /admin/api/:resource/:id
exports.update = async function (req, res, next) {
  const config = getResource(req, res);
  if (!config) return;
  if (config.readOnly || config.update === false) {
    return res.status(405).send({ success: false, message: 'Editing is not allowed for this section' });
  }
  if (!isObjectId(req.params.id)) return res.status(400).send({ success: false, message: 'Invalid id' });
  try {
    const Model = mongoose.model(config.model);
    const existing = await Model.findById(req.params.id);
    if (!existing) return res.status(404).send({ success: false, message: 'Not found' });

    const data = collectData(config, req, false);
    if (data.picture && existing.picture) deleteUpload(existing.picture);
    if (config.model === 'admin' && existing._id.equals(req.admin._id) && data.status !== undefined && data.status !== 1) {
      return res.status(400).send({ success: false, message: 'You cannot disable your own account' });
    }

    await Model.updateOne({ _id: existing._id }, { $set: data }, { runValidators: true });
    res.send({ success: true, message: 'Saved' });
  } catch (err) {
    const e = friendlyError(err);
    if (e) return res.status(e.status).send({ success: false, message: e.message });
    next(err);
  }
};

// DELETE /admin/api/:resource/:id
exports.remove = async function (req, res, next) {
  const config = getResource(req, res);
  if (!config) return;
  if (!isObjectId(req.params.id)) return res.status(400).send({ success: false, message: 'Invalid id' });
  try {
    const Model = mongoose.model(config.model);
    if (config.model === 'admin' && req.admin._id.equals(req.params.id)) {
      return res.status(400).send({ success: false, message: 'You cannot delete your own account' });
    }
    const doc = await Model.findByIdAndDelete(req.params.id);
    if (!doc) return res.status(404).send({ success: false, message: 'Not found' });
    if (doc.picture) deleteUpload(doc.picture);
    res.send({ success: true, message: 'Deleted' });
  } catch (err) {
    next(err);
  }
};
