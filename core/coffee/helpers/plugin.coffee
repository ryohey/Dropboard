fs =   require "fs"
path = require "../node_modules/path"

class Plugin
  constructor : () ->

  init : (pluginPath, dropboard, app, express) =>
    files = fs.readdirSync pluginPath
    plugins = []
    files.forEach (fileName) =>
      filePath = path.join pluginPath, fileName
      stat = fs.statSync filePath
      if stat.isDirectory()
        files2 = fs.readdirSync filePath
        for fileName2 in files2
          filePath2 = path.join filePath, fileName2
          switch fileName2 
            when "init.js"
              console.log filePath2
              plugins.push (require filePath2)
            when "public"
              stat2 = fs.statSync filePath2 
              if stat2.isDirectory()
                app.use "/plugins/"+fileName, express.static(filePath2)

    dropboard.config.menu = []
    for plugin in plugins
      plugin.init(dropboard)
      if plugin.menu
        dropboard.config.menu.push {
          name: plugin.menu
          url: plugin.name
        }

module.exports = Plugin