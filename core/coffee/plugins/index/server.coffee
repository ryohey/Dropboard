express = require "express"
Rest =    require "../../controllers/rest.coffee"

class Index extends Rest
  constructor : (appConfig) ->
    super("index", appConfig)
    @route = "/"

  bind : (app) ->
    super(app)
    app.use @route, express.static(@appConfig.paths.public)

  get : (req, res) =>
    console.log "res"
    res.render "index.ejs", {config: @appConfig}

module.exports = Index