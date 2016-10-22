fs =   require "fs"
path = require "path"

class Plugin
  constructor : () ->

  init : (plugins, dropboard, app, express) =>
    plugins.forEach (plugin) =>
      publicPath = path.resolve("./src/plugins/" + plugin.name + "/public")
      console.log publicPath
      app.use "/plugins/"+plugin.name, express.static(publicPath)

    dropboard.config.menu = []
    plugins.sort (a,b) ->
      a.priority ?= 0
      b.priority ?= 0
      b.priority - a.priority
      
    for plugin in plugins
      plugin.init(dropboard)
      if plugin.menu
        dropboard.config.menu.push {
          name: plugin.menu
          url: plugin.name
        }

module.exports = Plugin