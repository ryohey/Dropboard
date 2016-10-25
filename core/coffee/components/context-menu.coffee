$ = require "jQuery"
require "./context.sass"

module.exports = contextMenu = (x, y, title, cancelTitle, okTitle, items, complete) =>
  unless $("#contextMenu").length
    $("body").append("<div id='#contextMenu'></div>")

  elm = $("#contextMenu")
    .html("""
      <header>
        <h3>#{title}</h3>
      </header>
      <div class="content"></div>
      <footer>
        <a class="cancel button button_gray">#{cancelTitle}</a>
        <a class="ok button button_blue">#{okTitle}</a>
      </footer>
    """)
  elm.find(".content").append(items)
  elm.find(".ok").click () ->
    complete(elm)
  elm.find(".cancel").click () ->
    elm.hide()

  height = elm.height()
  width = elm.width()
  wWidth = $(window).width()
  wHeight = $(window).height()

  if wHeight < height + y
    y = y - height

  if wWidth < width + x
    x = wWidth - width


  elm
    .css({
      left: x
      top: y
    })
    .show()
  elm.find("input:first").focus()
  elm
