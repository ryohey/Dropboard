Plugin = require "./server.coffee"

module.exports = {
  name: "calendar"
  menu: "Calendar"
  init: (dropboard) ->
    plugin = new Plugin(dropboard.config)
    plugin.bind(dropboard.app)
}