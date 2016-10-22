module.exports = {
  name: "upload"
  menu: "Upload"
  init: (dropboard) ->
    Plugin = require "./server.js"
    plugin = new Plugin(dropboard.config)
    plugin.bind(dropboard.app)
}