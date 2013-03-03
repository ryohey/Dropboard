express =   require __dirname+"/node_modules/express" 
request =   require __dirname+"/node_modules/request" 
socket =    require __dirname+"/node_modules/socket.io"
ejs =       require __dirname+"/node_modules/ejs"
path =      require __dirname+"/node_modules/path"
partials =  require __dirname+"/node_modules/express-partials"
Watcher =   require __dirname+"/helpers/watcher" 
Port =      require __dirname+"/helpers/port" 
Plugin =    require __dirname+"/helpers/plugin" 
fs =        require "fs"

class Dropboard
  constructor : (config) ->
    @config = config
    @makeDataDir @config.paths.data
    @app = @initApp()
    @server = @initServer()
    @initPlugin()
    @bindRestart()

  makeDataDir : (dataPath) =>
    console.log dataPath
    fs.mkdirSync(dataPath, "757") unless fs.existsSync dataPath

  run : () =>
    port = (new Port(50000, __dirname)).port
    @server.listen(port)
    @url = "http://localhost:" + port + "/"

  # 起動に失敗した場合は起動済みDropboardを終了させ、再度起動を試みる(それでも出来なかった場合は諦める)
  bindRestart : () =>
    process.on 'uncaughtException', (err) =>
      console.log err
      if err.errno is 'EADDRINUSE'
        request @url+"exit", (error, response, body) =>
          console.log "restart"
          @run()

  initServer : () =>
    server = require('http').createServer(@app)
    io = socket.listen(server)
    watcher = new Watcher(io, @config.paths.data)
    watcher.start()
    server

  initPlugin : () =>
    new Plugin().init(@config.paths.plugins, @, @app, express)

  initApp : () =>
    app = express();
    app.use require('connect').bodyParser()
    app.use partials()

    ### Template Setting ###
    app.engine '.html', ejs.__express
    app.set 'view engine', 'ejs'
    app.set 'views', @config.paths.views

    ### localhost以外からのアクセスは400で応答 ###
    app.use (req, res, next) ->
      hostname = req.headers.host
      if hostname?.match(/^localhost/)?.length?
        next()
      else
        res.send(400)
      
    ### Root API ### 
    app.get "/exit", (req, res) ->
      console.log "httpからサーバーが終了されました"
      process.exit(0)

    app

module.exports = Dropboard