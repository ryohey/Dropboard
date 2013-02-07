var Log, fs, os, path, util;

path = require("path");

os = require("os");

util = require("util");

fs = require("fs");

Log = (function() {

  function Log(isDevMode, basePath) {
    var LOG_FILE,
      _this = this;
    this.basePath = basePath;
    this.fileName = "log.txt";
    LOG_FILE = this.makeLogfileName();
    /* 標準出力を上書き
    */
    this.echo = console.log;
    this.stdout = this.echo;
    this.print = this.echo;
    if (isDevMode) {
      this.echo("[Development mode]\nstart logging to " + LOG_FILE);
    } else {
      console.log = function() {
        var scr;
        scr = util.format.apply(_this, arguments) + '\n';
        return fs.appendFileSync(LOG_FILE, "[" + _this.dateFormat(new Date()) + "]" + scr);
      };
    }
    console.log("start logging");
  }

  Log.prototype.dateFormat = function(date) {
    return date.getFullYear() +"/"+ date.getMonth()+1 +"/"+ date.getDate() +" "+ date.getHours() +":"+ date.getMinutes() +":"+ date.getSeconds();
  };

  /**
   * Dropboard.exeが入っているディレクトリとその親ディレクトリの名前を
   * 使用してlogファイル名を作る.
   * 親ディレクトリも含める理由は現在のDropboard開発室の様に
   * Dropboard開発室
   *   |-dropboard
   * のような配置をされると容易にファイル名がかぶってしまうので
   * それを避けるために親ディレクトリも含めることにした.
  */

  Log.prototype.makeLogfileName = function() {
    var baseDir, parentDir;
    baseDir = path.basename(path.resolve(this.basePath));
    parentDir = path.basename(path.dirname(path.resolve(this.basePath)));
    return os.tmpDir() + parentDir + "_" + baseDir + ".log";
  };

  return Log;

})();

module.exports = Log;
