#
#    ポップアップ
#
class LBNotify
  constructor : () ->
    @NOTIFY_MIN_TIME = 500 #閉じる最短時間
    @elm = $("<div/>").attr("id", "lbNotify" + $(".lbNotify").length).addClass("lbNotify").append($("<div/>").addClass("inner"))
    @timer = null
    @lastShow = 0

  _show : (message, className) =>
      @lastShow = new Date()
      @elm.find(".inner").text message
      @elm.removeClass("notice progress warning").addClass(className).stop().animate
        opacity: "1"
      , 400

  _setWillHide : (time) =>
    clearTimeout @timer  if @timer?
    @timer = setTimeout( () =>
      @hide()
    , time)
  
  #ただのメッセージ
  notice : (message) =>
    @_show message, "notice"
    @_setWillHide 2000

  #ぐるぐる付き
  progress : (message) =>
    @_show message, "progress"

  #赤い
  warning : (message) =>
    @_show message, "warning"
    @_setWillHide 2000

  #閉じる
  hide : () =>
    interval = new Date() - @lastShow
    if interval > @NOTIFY_MIN_TIME
      @elm.stop().animate
        opacity: "0"
      , 400
    else
      @_setWillHide @NOTIFY_MIN_TIME - interval

  #表示位置の設定
  setPosition : (position) =>
    if position is "top"
      @elm.css
        top: "0"
        left: "0"

    else if position is "bottom"
      @elm.css
        bottom: "0"
        left: "0"