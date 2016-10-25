fs =      require "fs"
Reader =  require "../../helpers/reader.coffee"
Q =       require "../../helpers/array-query.coffee"
Controller = require "../controller.coffee"
layout =     require "../../views/layout.coffee"
view =       require "./view.ejs"

class Note extends Controller
  constructor : (appConfig) ->
    super("note", appConfig)

  post : (req, res) =>
    data = req.body
    fs.writeFile @dataPath+"note.txt", JSON.stringify(data), (err) ->
      console.log err if err
      res.send !err

  get : (req, res) =>
    res.format {
      json: () =>
        res.send @reader.get().all()
      html: () =>
        res.send layout(view(), @appConfig)
    }

module.exports = Note