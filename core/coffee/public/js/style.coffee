# onload
$ ->
  
  # クッキー
  $("link").attr "href", $.cookie("color")  if $.cookie("color")?
  
  # カラーセレクタ
  $("#colorSelector ul li").click ->
    css = $(this).attr("style-src")
    $("link").attr "href", css
    $.cookie "color", css,
      expires: 30




#$("#colorSelector ul li:first").click();