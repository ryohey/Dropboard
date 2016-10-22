fs = require "fs"
ArrayQuery = require "./array-query.coffee"

class Reader
  constructor : (dataPath) ->
    @dataPath = dataPath
    fs.mkdirSync(@dataPath, "757") unless fs.existsSync @dataPath

  get : () ->
    files = fs.readdirSync @dataPath
    list = []
    files.forEach (fileName) =>
      file = fs.readFileSync(@dataPath + fileName) + ""
      if file
        try
          data = JSON.parse file
          if data
            switch Object.prototype.toString.call data
              when "[object Array]"
                Array.prototype.push.apply list, data
              when "[object Object]"
                list.push data

        catch e
          console.log e
    new ArrayQuery(list)

module.exports = Reader