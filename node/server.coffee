express = require("express")
fs = require("fs")
app = express()
app.use require("connect").bodyParser()

DATA_PATH = "../data/"
UPLOAD_PATH = "../uploads/"
PUBLIC_PATH = "../public/"

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

app.get "/page/:page/:per", (req, res) ->
  files = getFiles(DATA_PATH)
  files.sort(sortByDate)
  page = parseInt(req.params.page)
  per = parseInt(req.params.per)
  sliced = files.slice(page*per,(page+1)*per)
  res.send JSON.stringify(sliced)

app.get "/read", (req, res) ->
  res.send JSON.stringify(getFiles(DATA_PATH))

app.use "/", express.static(__dirname + "/" + PUBLIC_PATH)
app.use "/uploads", express.static(__dirname + "/" + UPLOAD_PATH)
app.listen 3141