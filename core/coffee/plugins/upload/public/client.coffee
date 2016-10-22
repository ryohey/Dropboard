module.exports = (path) ->
  return unless path is "/upload"

  $("#uploads li a").each () ->
    url = new URLParser $(@).attr("href")
    switch url.type
      when "image"
        $(@)
          .html("<img src=\"#{url.url}\" class=\"item\">")
          .fancybox()
      when "audio"
        $(@).replaceWith("<audio src=\"#{url.url}\" controls=\"controls\" class=\"item\" preload=\"none\">")
      when "video"
        $(@).replaceWith("<video src=\"#{url.url}\" controls=\"controls\" class=\"item\" preload=\"none\">")
      else
        $(@).addClass("item")
    console.log url.type