Plugin = require "./server.coffee"

module.exports = {
  name: "upload"
  menu: "Upload"
  init: (dropboard) ->
    plugin = new Plugin(dropboard.config)
    plugin.bind(dropboard.app)
}