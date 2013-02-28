Rest =    require "../../controllers/rest"
Reader =  require "../../helpers/reader"
Q =       require "../../helpers/array-query"
fs =      require "fs"

module.exports = 
class Timeline extends Rest
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
      res.send 400, "invalid input"

  archive : (req, res) =>
    allData = JSON.stringify(@reader.get().all())
    for file in fs.readdirSync @dataPath
      filePath = @dataPath+file
      fs.unlink filePath if fs.existsSync filePath
    fs.writeFile @dataPath+"/archive", allData
    res.set {Location: "/timeline"}
    res.send 302

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
        res.render __dirname+"/view.ejs", {config: @appConfig}
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