express = require("express")
fs = require("fs")
os = require("os")
request = require("request")
util = require('util')

### 定数 ###
BASE_PATH = "../../../../"  # Dropboard.appの上
DATA_PATH = BASE_PATH+"data/"
UPLOAD_PATH = BASE_PATH+"uploads/"
PUBLIC_PATH = "../public/"
LOG_FILE = "log.txt"

### 標準出力を上書き ###
echo = console.log
console.log = () ->
  scr = util.format.apply(this, arguments) + '\n'   # console.logの実装と同じ
  fs.appendFileSync LOG_FILE, scr

### app ###
app = express();

# localhost以外からのアクセスは400で応答
app.use (req, res, next) ->
  hostname = req.headers.host
  if hostname? and hostname.match(/^localhost/)?.length?
    next()
  else
    res.send(400)

### static ###
app.use "/", express.static(__dirname + "/" + PUBLIC_PATH)
app.use "/uploads", express.static(__dirname + "/" + UPLOAD_PATH)

### データディレクトリがない場合は作成 ###
dirs = [DATA_PATH, UPLOAD_PATH];
for dir in dirs
  try
    fs.statSync(dir)
  catch e
    fs.mkdirSync(dir, "777")

### 内部で使う関数 ###
getFiles = (dataPath) ->
  files = fs.readdirSync(dataPath)
  list = []
  files.forEach (fileName) ->
    if fileName.match(/.+\.json/)
      file = fs.readFileSync(dataPath + fileName) + ""
      if file
        data = null
        try
          data = JSON.parse(file)
        catch e
          console.log e
        list.push data  if data
  list

isSet = (arg) ->
  return arg? and arg isnt ""

shorten = (str, length) ->
  s = str.replace(/\n|\\|\/|\:|\*|\?|\"|\<|\>|\|/g, "")
  postfix = "..."
  if s.length > length
    if length > postfix.length
      s.slice(0, length - postfix.length) + postfix
    else
      s.slice 0, length
  else
    s

sortByDate = (a, b) ->
    unless a
        return -1;
    else unless b
        return 1;
    ax = (new Date(a.date)).getTime()
    bx = (new Date(b.date)).getTime()
    ax ?= 0
    bx ?= 0
    ax - bx

### API ###
app.post "/upload", (req, res) ->
  files = req.files.files
  if typeof files.forEach isnt 'function'
    files = [files]
  saved = []
  files.forEach (file) ->
    data = fs.readFileSync file.path
    if data
      newPath = __dirname + "/" + UPLOAD_PATH + file.name;
      fs.writeFileSync newPath, data
      console.log "saved:"+file.name
      saved.push(UPLOAD_PATH + file.name)

  res.send JSON.stringify(saved)

app.post "/write", (req, res) ->
  data = req.body
  if isSet(data.name) and isSet(data.date) and isSet(data.text)
    fs.writeFile DATA_PATH + shorten(data.name, 10) + "「" + shorten(data.text, 20) + "」" + ".json", JSON.stringify(data), (err) ->
      if err
        res.send "0"
      else
        res.send "1"

app.get "/page/:page/:per", (req, res) ->
  files = getFiles(DATA_PATH)
  files.sort(sortByDate)
  page = parseInt(req.params.page)
  per = parseInt(req.params.per)
  start = Math.max(files.length - (page+1)*per, 0)
  end = Math.max(files.length - page*per,0)
  sliced = files.slice(start,end)  #新しいやつからとってくる
  res.send JSON.stringify(sliced)

app.get "/read", (req, res) ->
  res.send JSON.stringify(getFiles(DATA_PATH))

app.get "/exit", (req, res) ->
  console.log "httpからサーバーが終了されました"
  process.exit(0)

###* 
 * ポート番号の設定
 * macとwindowsではコロン(:)がディレクトリ名に使えない文字なので
 * ドライブ文字と被らない::をセパレータとして使う
 * 実行しているディレクトリ::portの並びで保存する
 ###
checkPort = ->
  dirToPortString = (port) ->
    runtime_dir + separator + port + "\n"

  portfile = os.tmpDir() + "/.dropboard.port"
  runtime_dir = __dirname
  default_port = 50000
  port = default_port
  separator = "::"

  detected = false
  exists = fs.existsSync(portfile)
  if exists
    file = fs.readFileSync(portfile, "utf-8")
    lines = file.split("\n")
    lines.forEach (line) ->
      pear = line.split(separator)
      if pear.length is 2 and pear[0] is runtime_dir
          port = Number(pear[1])
          detected = true  
    unless detected 
      port = default_port + lines.length
  
  portDirString = runtime_dir + separator + port + "\n"

  # 未登録なので新しく登録する
  if not detected or not exists
    fs.appendFileSync portfile, portDirString, "utf-8"
  port

# ポート番号の取得
port = checkPort()
url = "http://localhost:" + port + "/"

# 起動に失敗した場合は起動済みDropboardを終了させ、再度起動を試みる(それでも出来なかった場合は諦める)
process.on 'uncaughtException', (err) ->
  if err.errno is 'EADDRINUSE'
    request url+"exit", (error, response, body) ->
      startListen()

### WebSocketの準備 ###
server = require('http').createServer(app)
io = require('socket.io').listen(server)
io.set('log level',  1) # 標準だとログが出まくるので抑制
io.sockets.on 'connection',  (socket) ->
  ###*
   * クライアントからの接続時にDATA_PATHの
   * 監視を開始する.
   ###
  watcher = fs.watch DATA_PATH, (event,  filename) ->
    ###*
     * ディレクトリに変更があった際にupdateイベントを
     * クライアントにpushする.
     ###
    socket.emit 'update', {}

  ###*
   * クライアントから切断された際に
   * ディレクトリの監視を停止する.
   ###
  socket.on 'disconnect', () ->
    watcher.close()

###*
 * expressのインスタンスではなく
 * httpServerのインスタンスでlistenすること！
 * そうしないとsocket.io.jsが404になる.
 ###
startListen = () ->
  server.listen port

# サーバー起動
startListen()

# URLを出力して完了
echo url
