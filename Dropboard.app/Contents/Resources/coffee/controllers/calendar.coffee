fs = require("fs")
Rest = require("./rest")
Reader = require("../helpers/reader")

class Calendar extends Rest
  constructor : (appConfig) ->
    super("calendar", appConfig)

  post : (req, res) =>
    data = req.body
    fileName = @makePath(data)
    @writeData(data, res, fileName)

  get : (req, res) =>
    res.format {
      json: () =>
        res.send @reader.get().all()
      html: () =>
        res.render @name, {
          title: @appConfig.name
        }
    }

  put : (req, res) =>
    data = req.body
    data.allDay = data.allDay == "true"
    fileName = @makePath(data)
    fs.unlinkSync fileName
    @writeData(data, res, fileName)

  delete : (req, res) =>
    data = req.body
    console.log "delete:"+data._id
    data = req.body
    fs.unlink @makePath(data), (err) ->
      if err
        res.send 500, "Can't Delete"
      else
        res.send 200, "Deleted"

  writeData : (data, res, fileName) =>
    unless fs.existsSync fileName
      fs.writeFile fileName, JSON.stringify(data), (err) =>
        if (err)
          res.send 500, "Can't Write File"
        else
          res.send 200, "Created"
    else
      res.send 403, "File Already Exists"
      
  makePath : (data) =>
    @dataPath+data._id

  getScheduleName : (data) =>
    (data.title+data.start).replace /[\s\\\/\:\*\?\"\<\>\|\#\{\}\%\&\~]/mg, ""

module.exports = Calendar