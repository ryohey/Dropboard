fs = require("fs")
Rest = require("./rest")
Reader = require("./reader")

class Upload extends Rest
  constructor : () ->
    super("upload")

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