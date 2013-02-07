fs = require("fs")
Rest = require("./rest")
Reader = require("./reader")

class Upload extends Rest
  constructor : () ->
    super("upload")

  post : (req, res) ->
    files = req.files.files
    if typeof files.forEach isnt 'function'
      files = [files]
    saved = []
    files.forEach (file) ->
      data = fs.readFileSync file.path
      if data
        newPath = __dirname + "/" + @dataPath + file.name;
        fs.writeFileSync newPath, data
        console.log "saved:"+file.name
        saved.push(@dataPath + file.name)
    res.send JSON.stringify(saved)

  get : (req, res) ->
    fileName = req.params.name
    if fs.existsSync fileName
      res.send fs.readFileSync(@dataPath + fileName)
    else
      res.send 404, "Not Found"

module.exports = Upload