express = require "express"
Controller = require "../controller.coffee"

class Index extends Controller
  constructor : (appConfig) ->
    super("index", appConfig)
    @route = "/"

  bind : (app) ->
    super(app)
    app.use @route, express.static(@appConfig.paths.public)

  get : (req, res) =>
    res.render "index.ejs", {config: @appConfig}

module.exports = Index