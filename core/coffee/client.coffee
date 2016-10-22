Shared = require "./public/js/client.coffee"
Note = require "./plugins/note/public/client.coffee"
Calendar =  require "./plugins/calendar/public/client.coffee"
Timeline =  require "./plugins/timeline/public/client.coffee"
Upload =  require "./plugins/upload/public/client.coffee"

(() ->
  plugins = [Shared, Note, Calendar, Timeline, Upload]
  for plugin in plugins
    plugin(location.pathname)
)()
