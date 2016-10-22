path = require "path"
os = require "os"
util = require "util"
fs = require "fs"

class Log
  constructor : (isDevMode, basePath = "") ->
    @basePath = basePath
    @fileName = "log.txt"
    
    # ログのファイルはテンポラリに保存する.
    LOG_FILE = @makeLogfileName()

    ### 標準出力を上書き ###
    @echo = console.log
    @stdout = @echo
    @print = @echo

    if isDevMode
      @echo "[Development mode]\nstart logging to "+LOG_FILE  #場所を表示
    else
      console.log = () =>
        scr = util.format.apply(this, arguments) + '\n'  # console.logの実装と同じ
        fs.appendFileSync LOG_FILE, "["+@dateFormat(new Date())+"]"+scr

    console.log "start logging"

  dateFormat : (date) ->
    `date.getFullYear() +"/"+ date.getMonth()+1 +"/"+ date.getDate() +" "+ date.getHours() +":"+ date.getMinutes() +":"+ date.getSeconds()`

  ###*
   * Dropboard.exeが入っているディレクトリとその親ディレクトリの名前を
   * 使用してlogファイル名を作る.
   * 親ディレクトリも含める理由は現在のDropboard開発室の様に
   * Dropboard開発室
   *   |-dropboard
   * のような配置をされると容易にファイル名がかぶってしまうので
   * それを避けるために親ディレクトリも含めることにした.
   ###
  makeLogfileName : () ->
    baseDir = path.basename(path.resolve(@basePath))
    parentDir = path.basename(path.dirname(path.resolve(@basePath)))
    os.tmpDir() + "/" + parentDir + "_" + baseDir + ".log"

module.exports = Log