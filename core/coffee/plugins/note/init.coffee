Plugin = require "./server.coffee"

module.exports = {
  name: "note"
  menu: "Note"
  init: (dropboard) ->
    plugin = new Plugin(dropboard.config)
    plugin.bind(dropboard.app)
}