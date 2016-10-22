fs =        require "fs"
path =      require "path"

### my modules ###
Log =       require "./helpers/log.coffee" 
Dropboard = require "./dropboard.coffee"

### Plugins ###
Index =     require "./plugins/index/init.coffee"
Timeline =  require "./plugins/timeline/init.coffee"
Calendar =  require "./plugins/calendar/init.coffee"
Note =      require "./plugins/note/init.coffee"
Upload =    require "./plugins/upload/init.coffee"

###
 * node実行時に-dオプションが渡されていたらディベロップメントモード.
 * node server.js -d
 ### 
isDevelopMode = () -> (process.argv.length > 2) and (process.argv[2] is "-d")
log = new Log(isDevelopMode())

### Application Configuration ###
config = {
  name : ""
  location : path.resolve("") + "/"
  paths : {
    data : "data/"
    public : "src/public/"
    views : "src/views/"
  }
  plugins : [Index, Timeline, Calendar, Note, Upload]
}
dropboard = {}
dropboard.config = config

config.name = fs.realpathSync(config.location+"../").replace(/.*[\\\/](.+?)$/, "$1");

for key, value of config.paths
  config.paths[key] = path.join config.location, value

dropboard = new Dropboard(config)

# URLを出力して完了
log.echo dropboard.run()