$ = require "jQuery"
Shared =   require "./controllers/shared/client/index.coffee"
Note =     require "./controllers/note/client/index.coffee"
Calendar = require "./controllers/calendar/client/index.coffee"
Timeline = require "./controllers/timeline/client/index.coffee"
Upload =   require "./controllers/upload/client/index.coffee"

window.$ = window.jQuery = $

$(() ->
  controllers = [Shared, Note, Calendar, Timeline, Upload]
  for controller in controllers
    controller(location.pathname)
)
