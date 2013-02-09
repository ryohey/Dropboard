lbAjax = new LBAjax
lbNotify = new LBNotify

contextMenu = (x, y, title, cancelTitle, okTitle, items, complete) =>
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
  elm
    .css({
      left: x
      top: y
    })
    .show()
  elm.find("input:first").focus()
  elm

#  onload
$(() ->
  # 通知を追加
  lbNotify.elm.appendTo("body")
  lbNotify.setPosition("bottom")

  activePage = location.pathname.replace /^\//, "" 
  $("#side nav ul li").find("."+activePage).addClass("active")

  #  クッキー
  $("#user .name").val($.cookie('name'))
)