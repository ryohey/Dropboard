module.exports = class URLParser
  constructor : (url) ->
    @url = url
    slashes = url.split("/")
    if slashes.length > 0
      scheme = slashes[0].match(/.+?:/)
      @scheme = (if scheme? then scheme[0].replace(":", "") else undefined)
      hostname = url.replace(@scheme + "://", "").match(/^.+?\//)
      @hostname = (if hostname? then hostname[0].replace(/\//, "") else undefined)
      unless url.match(/\/$/)
        @fileName = slashes[slashes.length - 1]
        @extension = @fileName.replace(/^.+?\./, "")
        @type = @getType()

  #RFC 2045っぽく
  getType : () =>
    switch @extension.toLowerCase()
      when "jpg", "jpeg", "png", "gif"
        "image"
      when "mp3", "ogg", "wav"
        "audio"
      when "cmd", "css", "csv", "html", "txt", "xml"
        "text"
      when "mpg", "mp4", "wmv"
        "video"
