module.exports = {
  name: "timeline"
  menu: "Timeline"
  priority: 10
  init: (dropboard) ->
    Timeline = require "./server.js"
    timeline = new Timeline(dropboard.config)
    timeline.bind(dropboard.app)
}