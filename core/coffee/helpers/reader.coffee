fs = require("fs")
ArrayQuery = require("./array-query")

class Reader
  constructor : (dataPath) ->
    @dataPath = dataPath
    fs.mkdirSync(@dataPath, "757") unless fs.existsSync @dataPath

  get : () ->
    files = fs.readdirSync(@dataPath)
    list = []
    files.forEach (fileName) =>
      file = fs.readFileSync(@dataPath + fileName) + ""
      if file
        try
          data = JSON.parse(file)
          if data then list.push data
        catch e
          console.log e
    new ArrayQuery(list)

module.exports = Reader