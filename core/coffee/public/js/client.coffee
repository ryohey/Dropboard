Notify = require "./notify.coffee"
lbNotify = new Notify

#  onload
module.exports = () ->
  # 通知を追加
  lbNotify.elm.appendTo("body")
  lbNotify.setPosition("bottom")

  activePage = location.pathname.replace /^\//, "" 
  $("#side nav ul li").find("."+activePage).addClass("active")

  #  クッキー
  $("#user .name").val($.cookie('name'))
