fs = require "fs"

class Watcher
  constructor : (io, path) ->
    ### WebSocketの準備 ###
    @io = io
    @path = path
    console.log "watcher construct"

  start : () =>
    @io.set 'log level', 1 # 標準だとログが出まくるので抑制
    @io.sockets.on 'connection',  (socket) =>
      ###*
       * クライアントからの接続時にDATA_PATHの
       * 監視を開始する.
       ###

      @watchers = []
      for file in fs.readdirSync @path
        filePath = @path + file
        stats = fs.statSync filePath
        if stats.isDirectory()
          @watchers.push = fs.watch filePath, (event,  filename) =>
            socket.emit 'update'

      ###*
       * クライアントから切断された際に
       * ディレクトリの監視を停止する.
       ###
      socket.on 'disconnect', () =>
        watcher.close() for watcher in @watchers

module.exports = Watcher