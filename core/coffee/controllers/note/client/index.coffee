require "./style.sass"

module.exports = (path) ->
  return unless path is "/note"
  
  socket = io.connect(location.origin)
  update = () ->
    $.ajax {
      url: "/note"
      dataType: 'json'
      type: "get"
      success: (res) =>
        $("#note").val(res[0].note)
      error: (res) =>
        console.log res
    }

  socket.on 'update', update
  update()

  $("#send_note").click () ->
    $.ajax {
      url: '/note'
      type: 'post'
      data:  {note: $("#note").val()}
      success: (res) =>
        console.log res
      error: (res) =>
        console.log res
    }
