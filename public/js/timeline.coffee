
getFileHTML = (data) ->
  unless data.file then return ""
  fileHTML = $("<div/>").addClass("file")
  try
    files = JSON.parse(data.file)
    $.each files,(val,key) -> 
      elm = $("""
        <a target="_blank" href="#{key}"></a>
      """)
      if isImage(key)
        elm
          .fancybox()
          .append(
            $("<img/>").attr("src",key)
          )
      else if isAudio(key)
        # リンクはいらないのでelmを上書き
        elm = $("<audio/>")
          .attr("src",key)
          .attr("controls","controls")
      else
        fileName = parseURL(key).fileName
        elm.addClass("otherfile").text(fileName)
      
      fileHTML.append(elm)
  catch e
    console.log "filehtml error"

  return fileHTML

###  発言フィードを生成  ###
messageHTML = (data)  ->
  date = new Date(data.date)
  datestr = naturalFormatDate(date)
  fileHTML = getFileHTML(data)
  
  return $("""
    <article class="box">
      <header>
        <a rel="author">#{data.name}</a>
        <time>#{datestr}</text>
      </header>
      <p class="text">#{formatMessage(data.text)}</p>
    </article>
  """)
    .css("display", "none")
    .append(fileHTML)

###  全消去  ###
clear = () -> 
  $("#posts").html("")

###  アップデート処理  ###
update = () -> 
  lbAjax.update (data) -> 
    $.each data, () -> 
      messageHTML(this).prependTo("#posts").show("slow")

###  古いデータを取ってくる  ###
more = () -> 
  lbAjax.more (data) -> 
    data.reverse()
    $.each data, () -> 
      messageHTML(this).appendTo("#posts").show("slow")

###  書き込むボタン無効化  ###
disableWriteButton = () ->
  $("#write").attr("disabled", true)
  $("#write").addClass("disable")

###  書き込むボタン有効化  ###
enableWriteButton = () ->
  $("#write").attr("disabled", false)
  $("#write").removeAttr("disabled")
  $("#write").removeClass("disable")

###  「書き込む」ボタン押し下げ時  ###
writeButton = () ->
  disableWriteButton()
  files = $("#text").data("files")
  if (files)
    lbAjax.upload files,(response) ->
      console.log(response)
      $("#text")
        .data("files",null)
        .removeClass("attached")
      $("#files").html("")
      lbAjax.write({
        name:$("#name").val(),
        date:new Date(),
        text:$("#text").val(),
        file:response
      },() -> 
        $("#text").val("")
      )
  else
    lbAjax.write({
      name:$("#name").val(),
      date:new Date(),
      text:$("#text").val()
    },() ->
      $("#text").val("")
    )

  #  名前のクッキーを焼く
  $.cookie('name', $("#name").val(), {expires: 30})

  #  ファイル情報削除
  $('#files').empty()

  update()
  
$(() ->

  #  「書き込む」ボタン
  $("#write").click(writeButton)
  disableWriteButton()
  
  #  Ctrl+Enterで送信
  $(window).keydown (e) ->
    if e.ctrlKey and e.keyCode == 13
      if document.activeElement.id == 'text'
        if $("#text").val() != ""
          writeButton()
      event.preventDefault()
  
  #  textareaの監視
  $("#text")
    .bind('keyup change', () ->
      if $(this).val() == ""
        disableWriteButton()
      else
        enableWriteButton()
    )
    .bind("drop", (e) ->
      #  ドラッグされたファイル情報を取得
      files = e.originalEvent.dataTransfer.files
      console.log(files)
      $("#files").html("")
      $.each(files,() ->
        $("#files").append($("<li/>").text(this.name))
      )
      $(this).data("files",files)
      $(this).addClass("attached")
      e.preventDefault() 
      e.stopPropagation()
      $("#files").show()
    )

  #  クッキー
  $("#name").val($.cookie('name'))

  #  goTop
  topBtn = $('#goTop')   
  topBtn.hide()
  $(window).scroll () ->
    if $(this).scrollTop() > 100
      topBtn.fadeIn()
    else
      topBtn.fadeOut()
  topBtn.click () ->
    $('body,html').animate({
      scrollTop: 0
    }, 500)
    false

  #  投稿フォームを開く
  $("#text").focus () ->
    $(this).animate {
      height: "100px"
    }
    $("#posts").animate {
      "margin-top": "156px"
    }
  $("#text").blur () ->
    $(this).animate {
      height: "16px"
    }
    $("#posts").animate {
      "margin-top": "70px"
    }

  # 下まで来たらもっと読み込む
  $(window).bottom()
  $(window).bind "bottom", () ->
    more()

  # 更新の設定
  update()

)