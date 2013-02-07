class Watcher
  constructor : (io, path) ->
    ### WebSocketの準備 ###
    @io = io
    @path = path

  start : () ->
    @io.set('log level',  1) # 標準だとログが出まくるので抑制
    @io.sockets.on 'connection',  (socket) ->
      ###*
       * クライアントからの接続時にDATA_PATHの
       * 監視を開始する.
       ###
      watcher = fs.watch @path, (event,  filename) ->
        ###*
         * ディレクトリに変更があった際にupdateイベントを
         * クライアントにpushする.
         ###
        socket.emit 'update', {}

      ###*
       * クライアントから切断された際に
       * ディレクトリの監視を停止する.
       ###
      socket.on 'disconnect', () ->
        watcher.close()

module.exports = Watcher