Rest = require "./rest"
Reader = require "./reader"
Q = require "./array-query"
fs = require "fs"

class Timeline extends Rest
  constructor : () ->
    super("timeline")
    @ext = ""  #dataディレクトリに保存するメッセージの拡張子

  post : (req, res) =>
    data = req.body
    if @isSet data.name and @isSet data.date and @isSet data.text
      fileName = @digest(data)
      fs.writeFile fileName, JSON.stringify(data), (err) ->
        console.log err if err
        res.send !err

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
        res.render @name, {
          title: @appName
        }
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

module.exports = Timeline