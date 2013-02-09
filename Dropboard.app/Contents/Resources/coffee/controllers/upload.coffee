Rest =    require "./rest"
Reader =  require "../helpers/reader"
fs =      require "fs"
express = require "../node_modules/express"

class Upload extends Rest
  constructor : (appConfig) ->
    super("upload", appConfig)

  bind : (app) ->
    super(app)
    app.use @route, express.static(@dataPath)

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
        newPath = @dataPath + file.name
        fs.writeFileSync newPath, data
        saved.push(@name+ "/" + file.name)
    res.send JSON.stringify(saved)

  get : (req, res) =>
    fileName = req.params.name
    if fs.existsSync fileName
      res.send fs.readFileSync(@dataPath + fileName)
    else
      res.send 404, "Not Found"

module.exports = Upload