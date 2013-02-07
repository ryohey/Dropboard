var Port, fs, os;

os = require("os");

fs = require("fs");

/**
 * Registry（ポート番号とディレクトリがペアになったファイル）
 * を読み込んだり作成したり書き込んだりして使用可能なポート番号を取得する
 *
*/

Port = (function() {

  function Port(defaultPort, baseDir) {
    var regName;
    this.defaultPort = defaultPort;
    this.runtime_dir = baseDir;
    this.separator = "::";
    regName = os.tmpDir() + ".dropboard.port";
    if (!fs.existsSync(regName)) fs.writeFileSync(regName, "");
    this.load(regName);
    this.port = this.getRegistered();
    if (!this.port) {
      this.port = this.getAvailable(this.defaultPort);
      this.save(regName);
    }
    this.port;
  }

  Port.prototype.save = function(filePath) {
    var portDirString;
    portDirString = this.runtime_dir + this.separator + this.defaultPort + "\n";
    return fs.appendFileSync(filePath, portDirString, "utf-8");
  };

  Port.prototype.getRegistered = function() {
    var reg, _i, _len, _ref;
    _ref = this.registry;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      reg = _ref[_i];
      if (reg.dir === this.runtime_dir) return reg.port;
    }
    return null;
  };

  Port.prototype.getAvailable = function() {
    return this.defaultPort + this.registry.length;
  };

  /** 
   * 登録済みポート番号の取得と登録
  */

  Port.prototype.load = function(portfile) {
    var file, lines,
      _this = this;
    this.registry = [];
    file = fs.readFileSync(portfile, "utf-8");
    lines = file.split("\n");
    return lines.forEach(function(line) {
      var pear;
      pear = line.split(_this.separator);
      if (pear.length === 2) {
        return _this.registry.push({
          dir: pear[0],
          port: Number(pear[1])
        });
      }
    });
  };

  return Port;

})();

module.exports = Port;
