$ = require "jQuery"
Notify = require "../../../components/notify.coffee"
Cookies = require "js-cookie"
lbNotify = new Notify

require "./reset.css"
require "./style.sass"
require "./button.sass"

# 全ページ共通で走る onload
module.exports = () ->
  # 通知を追加
  lbNotify.elm.appendTo("body")
  lbNotify.setPosition("bottom")

  activePage = location.pathname.replace /^\//, "" 
  $("#side nav ul li").find("."+activePage).addClass("active")

  #  クッキー
  $("#user .name").val(Cookies.get('name'))
