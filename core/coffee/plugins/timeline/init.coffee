module.exports = {
  name: "timeline"
  menu: "タイムライン"
  init: (dropboard) ->
    Timeline = require "./server.js"
    timeline = new Timeline(dropboard.config)
    timeline.bind(dropboard.app)
}