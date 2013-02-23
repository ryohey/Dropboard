Rest = require "./rest"
express = require "../node_modules/express"

class Index extends Rest
  constructor : (appConfig) ->
    super("index", appConfig)
    @route = "/"

  bind : (app) ->
    super(app)
    app.use @route, express.static(@appConfig.paths.public)

  get : (req, res) =>
    res.render @name, {
      title: @appConfig.name
    }

module.exports = Index