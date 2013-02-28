Rest =    require "../../controllers/rest"
Reader =  require "../../helpers/reader"
express = require "../../node_modules/express"
path = require "../../node_modules/path"
crypto =  require "crypto"
fs =      require "fs"

class Upload extends Rest
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
        res.send 404, "Not Found"
    else
      files = fs.readdirSync(@dataPath)
      res.render __dirname+"/view.ejs", {
        config: @appConfig
        items: files
      }

module.exports = Upload