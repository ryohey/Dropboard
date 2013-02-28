Rest =    require "../../controllers/rest"
Reader =  require "../../helpers/reader"
Q =       require "../../helpers/array-query"
fs =      require "fs"

class Note extends Rest
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
        res.render __dirname+"/view.ejs", {config: @appConfig}
    }

module.exports = Note