module.exports = {
  name: "calendar"
  menu: "Calendar"
  init: (dropboard) ->
    Plugin = require "./server.js"
    plugin = new Plugin(dropboard.config)
    plugin.bind(dropboard.app)
}