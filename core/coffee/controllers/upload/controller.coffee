fs =      require "fs"
express = require "express"
path =    require "path"
crypto =  require "crypto"
Reader =  require "../../helpers/reader.coffee"
Controller = require "../controller.coffee"
layout =     require "../../views/layout.coffee"
view =       require "./view.ejs"

class Upload extends Controller
  constructor : (appConfig) ->
    super("upload", appConfig)

  bind : (app) ->
    super(app)
    app.use @route, express.static(@dataPath)
        
  md5 : (str) ->
    crypto.createHash('md5').update(str).digest("hex")

  post : (req, res) =>
    files = req.files.files
    console.log files
    if typeof files.forEach isnt 'function'
      files = [files]
    saved = []
    files.forEach (file) =>
      data = fs.readFileSync file.path
      console.log "from:"+file.path
      if data
        fileName = @md5(new Date().getTime().toString()) + path.extname(file.name)
        newPath = @dataPath + fileName
        fs.writeFileSync newPath, data
        saved.push(@name+ "/" + fileName)
    res.send JSON.stringify(saved)

  get : (req, res) =>
    fileName = req.params.name
    if fileName
      if fs.existsSync fileName
        res.send fs.readFileSync(@dataPath + fileName)
      else
        res.status(404).send "Not Found"
    else
      files = fs.readdirSync(@dataPath)
      res.send layout(view({items: files}), @appConfig)

module.exports = Upload