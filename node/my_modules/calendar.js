var Calendar, Reader, Rest, fs,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

fs = require("fs");

Rest = require("./rest");

Reader = require("./reader");

Calendar = (function(_super) {

  __extends(Calendar, _super);

  function Calendar() {
    this.getScheduleName = __bind(this.getScheduleName, this);
    this["delete"] = __bind(this["delete"], this);
    this.put = __bind(this.put, this);
    this.get = __bind(this.get, this);
    this.post = __bind(this.post, this);    Calendar.__super__.constructor.call(this, "calendar");
  }

  Calendar.prototype.post = function(req, res) {
    var data, fileName;
    data = req.body;
    fileName = this.dataPath + this.getScheduleName(data);
    if (!fs.existsSync(fileName)) {
      return fs.writeFile(fileName, JSON.stringify(data), function(err) {
        return res.send(!err);
      });
    } else {
      return res.send(false);
    }
  };

  Calendar.prototype.get = function(req, res) {
    var _this = this;
    return res.format({
      json: function() {
        return res.send(_this.reader.get().all());
      },
      html: function() {
        return res.render(_this.name, {
          title: _this.appName
        });
      }
    });
  };

  Calendar.prototype.put = function(req, res) {
    var data, fileName;
    data = req.body;
    return fileName = this.getScheduleName(data);
  };

  Calendar.prototype["delete"] = function(req, res) {
    var data;
    data = req.body;
    return fs.unlink(this.dataPath + this.getScheduleName(data));
  };

  Calendar.prototype.getScheduleName = function(data) {
    return (data.title + data.start).replace(/[\s\\\/\:\*\?\"\<\>\|\#\{\}\%\&\~]/mg, "");
  };

  return Calendar;

})(Rest);

module.exports = Calendar;
