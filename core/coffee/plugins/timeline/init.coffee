Timeline = require "./server.coffee"

module.exports = {
  name: "timeline"
  menu: "Timeline"
  priority: 10
  init: (dropboard) ->
    timeline = new Timeline(dropboard.config)
    timeline.bind(dropboard.app)
}
