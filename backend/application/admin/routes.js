// Admin dashboard API, mounted at /admin/api
const express = require('express');
const auth = require('./auth');
const crud = require('./crud');
const stats = require('./stats');

module.exports = function (app) {
  const router = express.Router();

  router.post('/auth/login', auth.login);

  // Everything below requires a logged-in admin
  router.use(auth.requireAdmin);
  router.get('/auth/me', auth.me);
  router.put('/auth/me', auth.updateMe);
  router.post('/auth/change-password', auth.changePassword);

  router.get('/stats/overview', stats.overview);
  router.get('/stats/reports', stats.reports);
  router.post('/messages/send', stats.sendMessage);

  router.get('/:resource', crud.list);
  router.get('/:resource/options', crud.options);
  router.get('/:resource/:id', crud.get);
  router.post('/:resource', crud.create);
  router.put('/:resource/:id', crud.update);
  router.delete('/:resource/:id', crud.remove);

  app.use('/admin/api', router);
};
