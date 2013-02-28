$ ->
  $("#uploads li a").each () ->
    url = new URLParser $(@).attr("href")
    switch url.type
      when "image"
        $(@).html("<img src=\"#{url.url}\" class=\"item\">")
      when "audio"
        $(@).replaceWith("<audio src=\"#{url.url}\" controls=\"controls\" class=\"item\">")
      when "video"
        $(@).replaceWith("<video src=\"#{url.url}\" controls=\"controls\" class=\"item\">")
      else
        $(@).addClass("item")
    console.log url.type