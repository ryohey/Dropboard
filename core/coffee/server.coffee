### my modules ###
fs =        require "fs"
path =      require __dirname+"/node_modules/path"
Log =       require __dirname+"/helpers/log" 
Dropboard = require __dirname+"/dropboard" 

###
 * node実行時に-dオプションが渡されていたらディベロップメントモード.
 * node server.js -d
 ### 
isDevelopMode = () -> (process.argv.length > 2) and (process.argv[2] is "-d")
log = new Log(isDevelopMode())

### Application Configuration ###
config = {
  name : ""
  location :  __dirname + "/../"
  paths : {
    data : "data/"
    public : "src/public/"
    views : "src/views/"
    plugins : "src/plugins/"
  }
}
dropboard = {}
dropboard.config = config

### Realize Paths ###
config.location = fs.realpathSync config.location
config.name = fs.realpathSync(config.location+"../../").replace(/.*[\\\/](.+?)$/, "$1");

for key, value of config.paths
  config.paths[key] = path.join config.location, value

dropboard = new Dropboard(config);

# URLを出力して完了
log.echo dropboard.run()