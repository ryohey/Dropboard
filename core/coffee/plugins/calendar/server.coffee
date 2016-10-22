fs =      require "fs"
Rest =    require "../../controllers/rest.coffee"
Reader =  require "../../helpers/reader.coffee"

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
        res.render "calendar.ejs", {config: @appConfig}
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
        res.status(500).send "Can't Delete"
      else
        res.status(200).send "Deleted"

  writeData : (data, res, fileName) =>
    unless fs.existsSync fileName
      fs.writeFile fileName, JSON.stringify(data), (err) =>
        if (err)
          res.status(500).send "Can't Write File"
        else
          res.status(200).send "Created"
    else
      res.status(403).send "File Already Exists"
      
  makePath : (data) =>
    @dataPath+data._id

  getScheduleName : (data) =>
    (data.title+data.start).replace /[\s\\\/\:\*\?\"\<\>\|\#\{\}\%\&\~]/mg, ""

module.exports = Calendar