var Reader, Rest, Upload, fs,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

fs = require("fs");

Rest = require("./rest");

Reader = require("./reader");

Upload = (function(_super) {

  __extends(Upload, _super);

  function Upload() {
    this.get = __bind(this.get, this);
    this.post = __bind(this.post, this);    Upload.__super__.constructor.call(this, "upload");
  }

  Upload.prototype.post = function(req, res) {
    var files, saved,
      _this = this;
    files = req.files.files;
    console.log(files);
    if (typeof files.forEach !== 'function') files = [files];
    saved = [];
    files.forEach(function(file) {
      var data, newPath;
      data = fs.readFileSync(file.path);
      console.log("from:" + file.path);
      if (data) {
        newPath = _this.dataPath + file.name;
        fs.writeFileSync(newPath, data);
        return saved.push(_this.name + "/" + file.name);
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
