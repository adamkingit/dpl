//Required dependencies
var express = require('express');
var bunyan = require('bunyan');
var prettyjson = require('prettyjson');
var moment = require('moment');
var versionInfo = require('./version.js');
var log = bunyan.createLogger({
  level: 'trace',
  name: 'echo-vcap'
});



var serverStartTime = moment();
var PORT = process.env.PORT || 3003;
var vcapInfo={env: 'dev'};
if(process.env.VCAP_APPLICATION){
  vcapInfo = JSON.parse(process.env.VCAP_APPLICATION);
}

//Create express server & socket.io
var app = express();
//app.use(require('express-bunyan-logger')());

function prettyPrintObject(req, rsp, obj){
  var options = {
    noColor: true
  };
  var responseString= '<pre>' + prettyjson.render(obj, options) + '</pre>';
  rsp.send(responseString);
}

function startServer(err) {
  log.trace('Setup express.');
  if(err) {
    log.error(err);
  } else {
    app.use('/vcap', (req, rsp) => {prettyPrintObject(req, rsp, vcapInfo);});
    app.use('/version', (req, rsp) => {prettyPrintObject(req, rsp, versionInfo);});
    app.get('/', function (req, res) {
      res.send('Server uptime: ' + moment.duration(moment().diff(serverStartTime)).humanize());
    });
    app.listen(PORT, '0.0.0.0', function () { //Start Express Server
      log.info('VCAP_APPLICATION echo app listening on port ' + PORT);
    });
  }
}

startServer();
