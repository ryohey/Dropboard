### bright modules ###
express =   require __dirname+"/node_modules/express" 
request =   require __dirname+"/node_modules/request" 
socket =    require __dirname+"/node_modules/socket.io"
ejs =       require __dirname+"/node_modules/ejs"
path =      require __dirname+"/node_modules/path"
partials =  require __dirname+"/node_modules/express-partials"
fs =        require "fs"

### my modules ###
Log =       require __dirname+"/helpers/log" 
Watcher =   require __dirname+"/helpers/watcher" 
Port =      require __dirname+"/helpers/port" 
Plugin =    require __dirname+"/helpers/plugin" 

### Application Configuration ###
config = {
  name : ""
  location :  __dirname + "/../"
  paths : {
    data : "data/"
    public : "src/public/"
    views : "src/views/"
    plugins : "src/plugins/"
  }
}
dropboard = {}
dropboard.config = config

config.location = fs.realpathSync config.location
config.name = fs.realpathSync(config.location+"../../../../").replace(/.*[\\\/](.+?)$/, "$1");

for key, value of config.paths
  config.paths[key] = path.join config.location, value


###
 * node実行時に-dオプションが渡されていたらディベロップメントモード.
 * node server.js -d
 ### 
isDevelopMode = () -> (process.argv.length > 2) and (process.argv[2] is "-d")
log = new Log(isDevelopMode())

### app ###
app = express();
dropboard.app = app
app.use require('connect').bodyParser()
app.use partials()

### Template Setting ###
app.engine '.html', ejs.__express
app.set 'view engine', 'ejs'
app.set 'views', config.paths.views

### localhost以外からのアクセスは400で応答 ###
app.use (req, res, next) ->
  hostname = req.headers.host
  if hostname?.match(/^localhost/)?.length?
    next()
  else
    res.send(400)

### Plugins ###
new Plugin().init(config.paths.plugins, dropboard, app, express)

### Root API ### 
app.get "/exit", (req, res) ->
  console.log "httpからサーバーが終了されました"
  process.exit(0)

# 起動に失敗した場合は起動済みDropboardを終了させ、再度起動を試みる(それでも出来なかった場合は諦める)
process.on 'uncaughtException', (err) ->
  if err.errno is 'EADDRINUSE'
    request url+"exit", (error, response, body) ->
      startListen()

### socket ###
server = require('http').createServer(app)
io = socket.listen(server)
watcher = new Watcher(io, config.paths.data)
watcher.start()

# ポート番号の取得
port = (new Port(50000, __dirname)).port 

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