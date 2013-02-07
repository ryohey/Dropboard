var Reader, Rest, Upload, fs,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

fs = require("fs");

Rest = require("./rest");

Reader = require("./reader");

Upload = (function(_super) {

  __extends(Upload, _super);

  function Upload() {
    Upload.__super__.constructor.call(this, "upload");
  }

  Upload.prototype.post = function(req, res) {
    var files, saved;
    files = req.files.files;
    if (typeof files.forEach !== 'function') files = [files];
    saved = [];
    files.forEach(function(file) {
      var data, newPath;
      data = fs.readFileSync(file.path);
      if (data) {
        newPath = __dirname + "/" + this.dataPath + file.name;
        fs.writeFileSync(newPath, data);
        console.log("saved:" + file.name);
        return saved.push(this.dataPath + file.name);
      }
    });
    return res.send(JSON.stringify(saved));
  };

  Upload.prototype.get = function(req, res) {
    var fileName;
    fileName = req.params.name;
    if (fs.existsSync(fileName)) {
      return res.send(fs.readFileSync(this.dataPath + fileName));
    } else {
      return res.send(404, "Not Found");
    }
  };

  return Upload;

})(Rest);

module.exports = Upload;
