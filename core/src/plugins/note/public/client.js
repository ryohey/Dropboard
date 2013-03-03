
$(function() {
  var socket, update;
  socket = io.connect('http://localhost');
  update = function() {
    var _this = this;
    return $.ajax({
      url: "/note",
      dataType: 'json',
      type: "get",
      success: function(res) {
        return $("#note").val(res[0].note);
      },
      error: function(res) {
        return console.log(res);
      }
    });
  };
  socket.on('update', update);
  update();
  return $("#send_note").click(function() {
    var _this = this;
    return $.ajax({
      url: '/note',
      type: 'post',
      data: {
        note: $("#note").val()
      },
      success: function(res) {
        return console.log(res);
      },
      error: function(res) {
        return console.log(res);
      }
    });
  });
});
