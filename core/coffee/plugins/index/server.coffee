Rest =    require "../../controllers/rest"
express = require "../../node_modules/express"

class Index extends Rest
  constructor : (appConfig) ->
    super("index", appConfig)
    @route = "/"

  bind : (app) ->
    super(app)
    app.use @route, express.static(@appConfig.paths.public)

  get : (req, res) =>
    res.render __dirname+"/view.ejs", {config: @appConfig}

module.exports = Index