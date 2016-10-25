express = require "express"
Controller = require "../controller.coffee"
layout =     require "../../views/layout.coffee"
view =       require "./view.ejs"

class Index extends Controller
  constructor : (appConfig) ->
    super("index", appConfig)
    @route = "/"

  bind : (app) ->
    super(app)
    app.use @route, express.static(@appConfig.paths.public)

  get : (req, res) =>
    res.send layout(view(), @appConfig)

module.exports = Index
