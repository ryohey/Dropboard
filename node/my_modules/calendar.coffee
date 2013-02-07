fs = require("fs")
Rest = require("./rest")
Reader = require("./reader")

class Calendar extends Rest
  constructor : () ->
    super("calendar")

  post : (req, res) =>
    data = req.body
    fileName = @dataPath+@getScheduleName(data)
    unless fs.existsSync fileName
      fs.writeFile fileName, JSON.stringify(data), (err) ->
        res.send !err
    else
      res.send false

  get : (req, res) =>
    res.format {
      json: () =>
        res.send @reader.get().all()
      html: () =>
        res.render @name, {
          title: @appName
        }
    }

  put : (req, res) =>
    data = req.body
    fileName = @getScheduleName(data)
    #なんかスケジュールごとのID的なやつを使って中身を書き換える
    #もしくは削除してからpostで作成させる

  delete : (req, res) =>
    data = req.body
    fs.unlink @dataPath+@getScheduleName(data)

  getScheduleName : (data) =>
    (data.title+data.start).replace /[\s\\\/\:\*\?\"\<\>\|\#\{\}\%\&\~]/mg, ""

module.exports = Calendar