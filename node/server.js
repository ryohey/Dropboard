var BASE_PATH, DATA_PATH, Log, PUBLIC_PATH, Port, Timeline, Upload, VIEW_PATH, Watcher, app, appName, ejs, express, io, isDevelopMode, log, path, port, request, server, socket, startListen, timeline, upload, url, watcher;

express = require("./node_modules/express");

request = require("./node_modules/request");

socket = require('./node_modules/socket.io');

ejs = require('./node_modules/ejs');

path = require("./node_modules/path");

/* my modules
*/

Log = require("./my_modules/log");

Watcher = require("./my_modules/watcher");

Timeline = require("./my_modules/timeline");

Port = require("./my_modules/port");

Upload = require("./my_modules/upload");

/* 定数
*/

BASE_PATH = "../";

DATA_PATH = BASE_PATH + "data/";

PUBLIC_PATH = "../public/";

VIEW_PATH = "../views/";

/*
 * node実行時に-dオプションが渡されていたらディベロップメントモード.
 * node server.js -d
*/

isDevelopMode = function() {
  return (process.argv.length > 2) && (process.argv[2] === "-d");
};

log = new Log(isDevelopMode());

/*
*/

appName = path.basename(path.resolve(__dirname, BASE_PATH));

/* app
*/

app = express();

app.use(require('connect').bodyParser());

/* Template Setting
*/

app.engine('.html', ejs.__express);

app.set('view engine', 'html');

app.set('views', __dirname + "/../views/");

/* static
*/

app.use("/", express.static(__dirname + "/" + PUBLIC_PATH));

/* localhost以外からのアクセスは400で応答
*/

app.use(function(req, res, next) {
  var hostname, _ref;
  hostname = req.headers.host;
  if ((hostname != null ? (_ref = hostname.match(/^localhost/)) != null ? _ref.length : void 0 : void 0) != null) {
    return next();
  } else {
    return res.send(400);
  }
});

/* API
*/

upload = new Upload();

timeline = new Timeline();

upload.bind(app);

timeline.bind(app);

app.get('/', function(req, res) {
  return res.render('index', {
    title: appName
  });
});

app.get("/exit", function(req, res) {
  console.log("httpからサーバーが終了されました");
  return process.exit(0);
});

process.on('uncaughtException', function(err) {
  if (err.errno === 'EADDRINUSE') {
    return request(url + "exit", function(error, response, body) {
      return startListen();
    });
  }
});

server = require('http').createServer(app);

io = socket.listen(server);

watcher = new Watcher(io, DATA_PATH);

watcher.start();

port = (new Port(50000, __dirname)).port;

log.echo(port);

/**
 * expressのインスタンスではなく
 * httpServerのインスタンスでlistenすること！
 * そうしないとsocket.io.jsが404になる.
*/

startListen = function() {
  return server.listen(port);
};

startListen();

url = "http://localhost:" + port + "/";

log.echo(url);
