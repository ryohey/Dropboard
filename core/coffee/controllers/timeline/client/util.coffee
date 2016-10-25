$ = require "jQuery"

#
#    特定のHTMLやURLに関係しないコード
#
sortByDate = (a, b) ->
  unless a
    return -1
  else return 1  unless b
  ax = (new Date(a.date)).getTime()
  bx = (new Date(b.date)).getTime()
  ax = (if ax then ax else 0)
  bx = (if bx then bx else 0)
  ax - bx

messageDiff = (before, after) ->
  added = []
  isExist = (that) ->
    flag = false
    $.each before, ->
      if @date is that.date and @text is that.text and @name is that.name
        flag = true
        return

    flag

  $.each after, ->
    added.push this  unless isExist(this)

  added

parseURL = (url) ->
  data = undefined
  hostname = undefined
  scheme = undefined
  slashes = undefined
  slashes = url.split("/")
  data = {}
  if slashes.length > 0
    scheme = slashes[0].match(/.+?:/)
    data.scheme = (if scheme? then scheme[0].replace(":", "") else undefined)
    hostname = url.replace(data.scheme + "://", "").match(/^.+?\//)
    data.hostname = (if hostname? then hostname[0].replace(/\//, "") else undefined)
    unless url.match(/\/$/)
      data.fileName = slashes[slashes.length - 1]
      data.extension = data.fileName.replace(/^.+?\./, "")
  data

isFileType = (file, extensions) ->
  ext = parseURL(file).extension
  flag = false
  $.each extensions, (val, key) ->
    if ext is key or ext is key.toUpperCase()
      flag = true
      false #breakの代わり

  flag

isImage = (file) ->
  isFileType file, ["jpg", "jpeg", "png", "gif"]

isAudio = (file) ->
  isFileType file, ["mp3", "ogg", "wav"]

youtubeDomainExp = /https?\:\/\/www\.youtube\.com.*/g
isYoutubeDomain = (url) ->
  if url.match(youtubeDomainExp)
    true
  else
    false

youtubeExp = /https?\:\/\/www\.youtube\.com\/watch\?v\=([a-zA-Z0-9_-]+).*/g
isYoutube = (url) ->
  if url.match(youtubeExp)
    true
  else
    false

twitterExp = /https?\:\/\/twitter\.com.*/g
isTwitter = (url) ->
  if url.match(twitterExp)
    true
  else
    false


# 日付関係
to2keta = (val) ->
  (if (val < 10) then "0" + val else val)

naturalFormatDate = (date) ->
  date.getFullYear() + "/" + to2keta(date.getMonth() + 1) + "/" + to2keta(date.getDate()) + " " + to2keta(date.getHours()) + ":" + to2keta(date.getMinutes())


# テキスト中の特定の文字列をフォーマット 
formatMessage = (str) ->
  
  # twitter風 
  hashPattern = /(?:^|[^ｦ-ﾟー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9&_\/]+)[#＃]([ｦ-ﾟー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9_]*[ｦ-ﾟー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z]+[ｦ-ﾟー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9_]*)/g
  urlPattern = /(https?:\/\/[a-zA-Z0-9;\/?:@&=\+$,\-_\.!~*'\(\)%#]+)/g
  h = (str) ->
    $("<div/>").text(str).html()

  replaceURL = (str) ->
    
    #タグの中に入ってないURLだけ変えたい
    urls = str.match(urlPattern)
    if urls
      $.each urls, (index, value) ->
        str = str.replace(value, "<a href=\"" + value + "\" target=\"_blank\">" + value + "</a>")  if not isYoutubeDomain(value) and not isTwitter(value)

    str

  replaceTwitter = (str) ->
    str = " " + str
    str = str.replace(/([^\w])\@([\w\-]+)/g, "$1@<a href=\"http://twitter.com/$2\" target=\"_blank\">$2</a>")
    str = str.replace(hashPattern, " <a href=\"http://twitter.com/search?q=%23$2\" target=\"_blank\">#$1</a>")
    str

  
  # youtube対応　
  replaceYoutube = (str) ->
    urls = str.match(urlPattern)
    iframes = []
    if urls
      $.each urls, (index, value) ->
        if isYoutube(value)
          src = value.replace(youtubeExp, "http://www.youtube.com/embed/$1")
          elm = $("<div/>").addClass("video").append($("<iframe/>").attr(
            width: "640"
            height: "360"
            src: src
            frameborder: "0"
            allowfullscreen: "true"
          ))
          iframes.push
            url: value
            html: elm.wrap("<div>").parent().html()


      $.each iframes, (index, value) ->
        str = str.replace(value.url, value.html)

    str

  replaceURL(replaceTwitter(replaceYoutube(h(str))));

module.exports = {
  sortByDate
  messageDiff
  parseURL
  isFileType
  isImage
  isAudio
  isYoutubeDomain
  isYoutube
  isTwitter
  to2keta
  naturalFormatDate
  formatMessage
}