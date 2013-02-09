Reader = require("./reader")

class Rest
  constructor : (name) ->
    @name = name
    @route = "/"+name
    appPath = __dirname+"/../"+"../"
    @dataPath = appPath+"data/"+name+"/"
    @reader = new Reader(@dataPath)
  bind : (app) ->
    app.post @route, @post
    app.put @route, @put
    app.get @route, @get
    app.delete @route, @delete
  post : (req, res) ->
    res.send 501, "Not Implemented"
  put : (req, res) ->
    res.send 501, "Not Implemented"
  get : (req, res) ->
    res.send 501, "Not Implemented"
  delete : (req, res) ->
    res.send 501, "Not Implemented"

module.exports = Rest