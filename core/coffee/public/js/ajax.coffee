#
#    通信部分だけ抜き出したクラス的なやつ
#	引数に通信完了時の処理を書く
#	lbAjax.read(function(data){
#		console.log(data);
#	})
#	こういう感じで
#
class LBAjax
  constructor : () ->
    @MESSAGE_PER_PAGE = 15
    @lastData = []  # 前回読み込んだデータ 
  
  # 指定数だけ読み込む 
  page : (success, page, per) =>
    lbNotify.progress "データ取得中"
    $.getJSON "/timeline",
      page: page
      per: per
    , (data) ->
      lbNotify.hide()
      success data

  # 差分を取得 
  _diff : (success, page, per) =>
    _success = success
    @page ((data) =>
      diff = messageDiff(@lastData, data)
      diff.sort sortByDate
      _success diff
      @lastData = @lastData.concat(diff)
    ), page, per

  # 最新のデータを取り出す 
  update : (success) =>
    @_diff success, 0, @MESSAGE_PER_PAGE
  
  # 過去のデータを取り出す 
  more : (success) =>
    @_diff success, Math.floor(@lastData.length / @MESSAGE_PER_PAGE), @MESSAGE_PER_PAGE

  # 書き込む 
  write : (data, success) =>
    lbNotify.progress "送信中"
    $.post "/timeline", data, (response) =>
      if response is "1"
        lbNotify.hide()
        success()
      else
        lbNotify.warning "送信に失敗しました"
  
  # アップロードする 
  upload : (files, success) =>
    fd = new FormData()

    for file in files
      fd.append "files", file

    lbNotify.progress "アップロード中"
    
    # XHR で送信
    $.ajax
      url: "/upload"
      type: "post"
      data: fd
      processData: false
      contentType: false
      success: (response) ->
        lbNotify.hide()
        success response