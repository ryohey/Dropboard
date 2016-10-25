layout = require "./layout.ejs"
header = require "./header.ejs"
footer = require "./footer.ejs"
side = require "./side.ejs"
_ = require "lodash"

module.exports = (content, config) ->
  layout
    header: header
    side: side
    footer: footer
    content: content
    config: config
    