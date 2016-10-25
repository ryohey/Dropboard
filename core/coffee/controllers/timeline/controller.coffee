fs =         require "fs"
Controller = require "../controller.coffee"
Reader =     require "../../helpers/reader.coffee"
Q =          require "../../helpers/array-query.coffee"
layout =     require "../../views/layout.coffee"
view =       require "./view.ejs"

module.exports = 
class Timeline extends Controller
  constructor : (appConfig) ->
    super("timeline", appConfig)
    @ext = ""  #dataディレクトリに保存するメッセージの拡張子

  bind : (app) ->
    super(app)
    app.get "/archive", @archive

  post : (req, res) =>
    data = req.body
    if @isSet data.name and @isSet data.date and @isSet data.text
      fileName = @digest(data)
      console.log fileName
      fs.writeFile fileName, JSON.stringify(data), (err) ->
        console.log err if err
        res.send !err
    else
      res.status(400).send "invalid input"

  archive : (req, res) =>
    files = fs.readdirSync @dataPath
    allData = JSON.stringify(@reader.get().all())
    for file in files
      filePath = @dataPath+file
      fs.unlink filePath if fs.existsSync filePath
    fs.writeFile @dataPath+"/archive", allData
    res.set {Location: "/timeline"}
    res.status(302).send()

  get : (req, res) =>
    res.format {
      json: () =>
        page = parseInt(req.query.page)
        per = parseInt(req.query.per)
        all = @reader.get().all()
        sorted = Q(all).sortByDate()
        data = Q(sorted).page(page, per)
        res.send data
      html: () =>
        res.send layout(view(), @appConfig)
    }

  digest : (data) ->
    fileName = @dataPath + @shorten(data.name, 10) + "「" + @shorten(data.text, 20) + "」" + @ext  
    if fs.existsSync fileName then fileName += ".0"
    fileCount = 0;
    while fs.existsSync fileName
      fileName = fileName.replace /\.[0-9]+$/, "."+(++fileCount)
    #同名ファイル存在時に末尾に".ファイル数"をつける ドットはshortenでエスケープしているので使用可能
    fileName

  isSet : (arg) ->
    arg? and arg isnt ""

  shorten : (str, length) ->
    s = str.replace(/\n|\\|\/|\:|\*|\?|\"|\<|\>|\|\.|/g, "")
    postfix = "..."
    if s.length > length
      if length > postfix.length
        s.slice(0, length - postfix.length) + postfix
      else
        s.slice 0, length
    else
      s