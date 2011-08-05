models = require 'expressway/models'
ew = require '../..'

app = module.exports = ew.createServer()

app.listen 4000
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);

