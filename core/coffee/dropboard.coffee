ejs =       require "ejs"
express =   require "express" 
request =   require "request" 
socket =    require "socket.io"
path =      require "path"
partials =  require "express-partials"
fs =        require "fs"
connect =   require "connect"
bodyParser= require "body-parser"
http =      require "http"
Watcher =   require "./helpers/watcher.coffee" 
Port =      require "./helpers/port.coffee"

class Dropboard
  constructor : (config) ->
    @config = config
    @makeDataDir @config.paths.data
    @app = @initApp()
    @server = @initServer()
    @initControllers()
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
    server = http.createServer(@app)
    
    io = socket(server,
      transports: ["websocket", "polling"]
    )

    watcher = new Watcher(io, @config.paths.data)
    watcher.start()
    server
    
  initControllers : () =>
    controllers = @config.controllers

    controllers.forEach (controller) =>
      publicPath = path.resolve("./src/controllers/" + controller.name + "/public")
      console.log publicPath
      @app.use "/controllers/"+controller.name, express.static(publicPath)

    @config.menu = []
    controllers.sort (a,b) ->
      a.priority ?= 0
      b.priority ?= 0
      b.priority - a.priority
      
    for controller in controllers
      ControllerClass = controller.controller
      instance = new ControllerClass(@config)
      instance.bind(@app)

      if controller.menu
        @config.menu.push {
          name: controller.menu
          url: controller.name
        }

  initApp : () =>
    app = express()
    app.use bodyParser.json()
    app.use bodyParser.urlencoded()
    app.use partials()

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