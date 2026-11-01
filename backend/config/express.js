const path = require('path');
const express = require('express');
const compression = require('compression');
const cors = require('cors');
const multer = require('multer');

module.exports = function () {
  const app = express();

  app.use(cors());
  app.use(compression());
  app.use(express.urlencoded({ extended: true, limit: '20mb' }));
  app.use(express.json({ limit: '20mb' }));
  app.use(multer({ dest: path.join(__dirname, 'data') }).any());
  // Express 5 leaves req.body undefined when there is no body
  app.use((req, res, next) => { req.body = req.body || {}; next(); });

  // Uploaded files (profile pictures, lab reports)
  app.use(express.static('./uploads', { maxAge: '1y' }));

  // Mobile-app API responses never include passwords, and push tokens are sealed.
  // (The admin dashboard API under /admin has its own field filtering.)
  const { sanitizeResponse } = require('../application/controller/utils');
  app.use((req, res, next) => {
    if (req.path.startsWith('/admin/')) return next();
    const json = res.json.bind(res);
    res.json = (body) => json(sanitizeResponse(JSON.parse(JSON.stringify(body ?? null))));
    next();
  });

  require('../application/routes/api-routes')(app);
  require('../application/admin/routes')(app);

  // JSON 404 for unknown endpoints
  app.use((req, res) => res.status(404).send({ success: false, message: 'Endpoint not found' }));

  // JSON error handler
  // eslint-disable-next-line no-unused-vars
  app.use((err, req, res, next) => {
    console.error(err);
    res.status(500).send({ success: false, message: 'Internal server error' });
  });

  return app;
};
