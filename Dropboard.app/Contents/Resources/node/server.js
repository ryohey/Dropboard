var DATA_PATH, PUBLIC_PATH, UPLOAD_PATH, app, dir, dirs, express, fs, getFiles, isSet, shorten, sortByDate, _i, _len;

express = require("express");

fs = require("fs");

app = express();

app.use(require("connect").bodyParser());

DATA_PATH = "../../../../data/";

UPLOAD_PATH = "../../../../uploads/";

PUBLIC_PATH = "../public/";

dirs = [DATA_PATH, UPLOAD_PATH];

for (_i = 0, _len = dirs.length; _i < _len; _i++) {
  dir = dirs[_i];
  try {
    fs.statSync(dir);
  } catch (e) {
    console.log("make directory:" + dir);
    fs.mkdirSync(dir, 0777);
  }
}

getFiles = function(dataPath) {
  var files, list;
  files = fs.readdirSync(dataPath);
  list = [];
  files.forEach(function(fileName) {
    var data, file;
    if (fileName.match(/.+\.json/)) {
      file = fs.readFileSync(dataPath + fileName) + "";
      if (file) {
        data = null;
        try {
          data = JSON.parse(file);
        } catch (e) {
          console.log(e);
        }
        if (data) return list.push(data);
      }
    }
  });
  return list;
};

isSet = function(arg) {
  return (arg != null) && arg !== "";
};

shorten = function(str, length) {
  var postfix, s;
  s = str.replace(/\n|\\|\/|\:|\*|\?|\"|\<|\>|\|/g, "");
  postfix = "...";
  if (s.length > length) {
    if (length > postfix.length) {
      return s.slice(0, length - postfix.length) + postfix;
    } else {
      return s.slice(0, length);
    }
  } else {
    return s;
  }
};

app.post("/upload", function(req, res) {
  var files, saved;
  files = req.files.files;
  if (typeof files.forEach !== 'function') files = [files];
  saved = [];
  files.forEach(function(file) {
    var data, newPath;
    data = fs.readFileSync(file.path);
    if (data) {
      newPath = __dirname + "/" + UPLOAD_PATH + file.name;
      fs.writeFileSync(newPath, data);
      console.log("saved:" + file.name);
      return saved.push(UPLOAD_PATH + file.name);
    }
  });
  return res.send(JSON.stringify(saved));
});

app.post("/write", function(req, res) {
  var data;
  data = req.body;
  if (isSet(data.name) && isSet(data.date) && isSet(data.text)) {
    return fs.writeFile(DATA_PATH + shorten(data.name, 10) + "「" + shorten(data.text, 20) + "」" + ".json", JSON.stringify(data), function(err) {
      if (err) {
        return res.send("0");
      } else {
        return res.send("1");
      }
    });
  }
});

sortByDate = function(a, b) {
  var ax, bx;
  if (!a) {
    return -1;
  } else if (!b) {
    return 1;
  }
  ax = (new Date(a.date)).getTime();
  bx = (new Date(b.date)).getTime();
  if (ax == null) ax = 0;
  if (bx == null) bx = 0;
  return ax - bx;
};

app.get("/page/:page/:per", function(req, res) {
  var end, files, page, per, sliced, start;
  files = getFiles(DATA_PATH);
  files.sort(sortByDate);
  page = parseInt(req.params.page);
  per = parseInt(req.params.per);
  start = Math.max(files.length - (page + 1) * per, 0);
  end = Math.max(files.length - page * per, 0);
  sliced = files.slice(start, end);
  return res.send(JSON.stringify(sliced));
});

app.get("/read", function(req, res) {
  return res.send(JSON.stringify(getFiles(DATA_PATH)));
});

app.use("/", express.static(__dirname + "/" + PUBLIC_PATH));

app.use("/uploads", express.static(__dirname + "/" + UPLOAD_PATH));

var os = require("os");
var fs = require("fs");

var portfile = os.tmpDir() + "/.dropboard.port";
var runtime_dir = __dirname;

// macとwindowsではコロン(:)がディレクトリ名に使えない文字なので
// ドライブ文字と被らない::をセパレータとして使う
// 実行しているディレクトリ::portの並びで保存する
var checkPort = function(){
    var default_port = 50000;
    var port = default_port;
    var separator = "::";

    var dirToPortString = function(port){
        return runtime_dir + separator + port +"\n";
    }
    var detected = false;
    var exists = fs.existsSync(portfile);
    if(exists){
        var file = fs.readFileSync(portfile, "utf-8");
        var lines = file.split("\n");
        lines.forEach(function(line){
            var pear = line.split(separator);
            if(pear.length == 2){
                port = Number(pear[1]);
                if(pear[0] === runtime_dir){
                    detected = true;
                }
            }

        });
        if(!detected){
            port = default_port + lines.length;
        }
    }
    // 未登録なので新しく登録する
    if (!detected || !exists){
        fs.appendFileSync(portfile, dirToPortString(port), "utf-8");
    }

    return port;
}
var port = checkPort();
var url = "http://localhost:" + port + "/";

// サーバ起動
app.listen(port);

// 生成したポート番号で起動
var exec = require("child_process");
if(os.type() === "Darwin"){
    //mac
    exec.exec("open " + url);
}else if (os.type() === "Windows_NT"){
    exec.exec("start " + url);
}

console.log(url);