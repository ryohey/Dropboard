var DATA_PATH, PUBLIC_PATH, UPLOAD_PATH, app, express, fs, getFiles, isSet, shorten, sortByDate;

express = require("express");

fs = require("fs");

app = express();

app.use(require("connect").bodyParser());

DATA_PATH = "../data/";

UPLOAD_PATH = "../uploads/";

PUBLIC_PATH = "../public/";

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
  var files, page, per, sliced;
  files = getFiles(DATA_PATH);
  files.sort(sortByDate);
  page = parseInt(req.params.page);
  per = parseInt(req.params.per);
  sliced = files.slice(page * per, (page + 1) * per);
  return res.send(JSON.stringify(sliced));
});

app.get("/read", function(req, res) {
  return res.send(JSON.stringify(getFiles(DATA_PATH)));
});

app.use("/", express.static(__dirname + "/" + PUBLIC_PATH));

app.use("/uploads", express.static(__dirname + "/" + UPLOAD_PATH));

app.listen(3141);
