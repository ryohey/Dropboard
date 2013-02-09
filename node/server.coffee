express = require "./node_modules/express" 
request = require "./node_modules/request" 
socket = require './node_modules/socket.io' 
ejs = require './node_modules/ejs' 
path = require "./node_modules/path"
partials = require './node_modules/express-partials'

crypto = require 'crypto'
fs = require "fs"

### my modules ###
Log =      require "./my_modules/log" 
Watcher =  require "./my_modules/watcher" 
Timeline = require "./my_modules/timeline" 
Port =     require "./my_modules/port" 
Upload =   require "./my_modules/upload" 
Calendar =   require "./my_modules/calendar" 

### 定数 ###
BASE_PATH = __dirname+"/../"  # Dropboard.appの上
DATA_PATH = BASE_PATH+"data/"
PUBLIC_PATH = BASE_PATH+"public/"
UPLOAD_PATH = BASE_PATH+"data/upload/"
VIEW_PATH = BASE_PATH+"views/"

### benri ###
md5 = (str) ->
  crypto.createHash('md5').update(str).digest("hex")

###
 * node実行時に-dオプションが渡されていたらディベロップメントモード.
 * node server.js -d
 ### 
isDevelopMode = () -> (process.argv.length > 2) and (process.argv[2] is "-d")
log = new Log(isDevelopMode())

### ###
appName = path.basename path.resolve(__dirname, BASE_PATH)

### app ###
app = express();
app.use require('connect').bodyParser()
app.use partials()

### Template Setting ###
app.engine '.html', ejs.__express
app.set 'view engine', 'ejs'
app.set 'views', VIEW_PATH

### static ###
app.use "/", express.static(PUBLIC_PATH)
app.use "/upload/", express.static(UPLOAD_PATH)

### localhost以外からのアクセスは400で応答 ###
app.use (req, res, next) ->
  hostname = req.headers.host
  if hostname?.match(/^localhost/)?.length?
    next()
  else
    res.send(400)

### API ###
upload = new Upload();
timeline = new Timeline();
calendar = new Calendar();
upload.appName = appName
timeline.appName = appName
calendar.appName = appName

upload.bind(app)
timeline.bind(app)
calendar.bind(app)

app.get "/exit", (req, res) ->
  console.log "httpからサーバーが終了されました"
  process.exit(0)

app.get "/", (req, res) ->
  res.render "index", {
    title: appName
  }

# 起動に失敗した場合は起動済みDropboardを終了させ、再度起動を試みる(それでも出来なかった場合は諦める)
process.on 'uncaughtException', (err) ->
  if err.errno is 'EADDRINUSE'
    request url+"exit", (error, response, body) ->
      startListen()

server = require('http').createServer(app)
io = socket.listen(server)
watcher = new Watcher(io, DATA_PATH+"timeline/")
watcher.start()

# ポート番号の取得
port = (new Port(50000, __dirname)).port 
log.echo port

###*
 * expressのインスタンスではなく
 * httpServerのインスタンスでlistenすること！
 * そうしないとsocket.io.jsが404になる.
 ###
startListen = () ->
  server.listen(port)

# サーバー起動
startListen()

# URLを出力して完了
url = "http://localhost:" + port + "/"
log.echo url