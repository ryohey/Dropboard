var Watcher;

Watcher = (function() {

  function Watcher(io, path) {
    /* WebSocketの準備
    */    this.io = io;
    this.path = path;
  }

  Watcher.prototype.start = function() {
    this.io.set('log level', 1);
    return this.io.sockets.on('connection', function(socket) {
      /**
       * クライアントからの接続時にDATA_PATHの
       * 監視を開始する.
      */
      var watcher;
      watcher = fs.watch(this.path, function(event, filename) {
        console.log("update!");
        /**
         * ディレクトリに変更があった際にupdateイベントを
         * クライアントにpushする.
        */
        return socket.emit('update', {});
      });
      /**
       * クライアントから切断された際に
       * ディレクトリの監視を停止する.
      */
      return socket.on('disconnect', function() {
        return watcher.close();
      });
    });
  };

  return Watcher;

})();

module.exports = Watcher;
