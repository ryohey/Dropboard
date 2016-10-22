Plugin = require "./server.coffee"

module.exports = {
  name: "index"
  init: (dropboard) ->
    plugin = new Plugin(dropboard.config)
    plugin.bind(dropboard.app)
}