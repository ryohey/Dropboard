lbAjax = new LBAjax
lbNotify = new LBNotify

#  onload
$(() ->
  # 通知を追加
  lbNotify.elm.appendTo("body")
  lbNotify.setPosition("bottom")

  activePage = location.pathname.replace /^\//, "" 
  $("#side nav ul li").find("."+activePage).addClass("active")
)