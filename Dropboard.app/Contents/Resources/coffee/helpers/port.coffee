os = require "os"
fs = require "fs"

###*
 * Registry（ポート番号とディレクトリがペアになったファイル）
 * を読み込んだり作成したり書き込んだりして使用可能なポート番号を取得する
 *
 ###
class Port
  constructor : (defaultPort, baseDir) ->
    @defaultPort = defaultPort
    @runtime_dir = baseDir
    @separator = "::" #ドライブ文字と被らない::をセパレータとして使う
    regName = os.tmpDir() + "/.dropboard.port"

    console.log regName
    #存在しなければ作成
    unless fs.existsSync regName
      fs.writeFileSync regName, ""

    @load(regName)

    @port = @getRegistered()
    unless @port # 未登録
      @port = @getAvailable(@defaultPort)
      @save(regName)# 新しく登録する

    @port

  #実行しているディレクトリ::portの並びで保存する
  save : (filePath) ->
    portDirString = @runtime_dir + @separator + @defaultPort + "\n"
    fs.appendFileSync filePath, portDirString, "utf-8"

  #このアプリケーションの登録済みポートを読み込む
  getRegistered : () ->
    for reg in @registry
      return reg.port if reg.dir is @runtime_dir
    null

  #使用可能ポートを取得
  getAvailable : () ->
    @defaultPort + @registry.length

  ###* 
   * 登録済みポート番号の取得と登録
   ###
  load : (portfile) ->
    @registry = []
    file = fs.readFileSync(portfile, "utf-8")
    lines = file.split("\n")
    lines.forEach (line) =>
      pear = line.split(@separator)
      if pear.length is 2
        @registry.push {
          dir: pear[0]
          port: Number(pear[1])
        }

module.exports = Port