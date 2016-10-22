ejs =       require "ejs"
express =   require "express" 
request =   require "request" 
socket =    require "socket.io"
path =      require "path"
partials =  require "express-partials"
fs =        require "fs"
connect =   require "connect"
bodyParser= require "body-parser"
Watcher =   require "./helpers/watcher.coffee" 
Port =      require "./helpers/port.coffee"
Plugin =    require "./helpers/plugin.coffee"

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
    @port = (new Port(50000, @config.location)).port
    @server.listen(@port)
    @url = "http://localhost:" + @port + "/"

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
    io = socket(server, {origins: "http://lopcalhost:" + @port})
    watcher = new Watcher(io, @config.paths.data)
    watcher.start()
    server

  initPlugin : () =>
    new Plugin().init(@config.plugins, @, @app, express)

  initApp : () =>
    app = express();
    app.use bodyParser.json()
    app.use bodyParser.urlencoded()
    app.use partials()

    ### Template Setting ###
    app.engine '.html', ejs.__express
    app.set 'view engine', 'ejs'
    console.log @config.paths.views
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