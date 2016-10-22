module.exports = {
  name: "note"
  menu: "Note"
  init: (dropboard) ->
    Plugin = require "./server.js"
    plugin = new Plugin(dropboard.config)
    plugin.bind(dropboard.app)
}