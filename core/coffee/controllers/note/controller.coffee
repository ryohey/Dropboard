fs =      require "fs"
Reader =  require "../../helpers/reader.coffee"
Q =       require "../../helpers/array-query.coffee"
Controller = require "../controller.coffee"

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
        res.render "note.ejs", {config: @appConfig}
    }

module.exports = Note