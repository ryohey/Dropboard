var clear, disableWriteButton, enableWriteButton, getFileHTML, messageHTML, more, update, writeButton;

getFileHTML = function(data) {
  var fileHTML, files;
  if (!data.file) return "";
  fileHTML = $("<div/>").addClass("file");
  try {
    files = JSON.parse(data.file);
    $.each(files, function(val, key) {
      var elm, fileName;
      elm = $("<a target=\"_blank\" href=\"" + key + "\"></a>");
      if (isImage(key)) {
        elm.fancybox().append($("<img/>").attr("src", key));
      } else if (isAudio(key)) {
        elm = $("<audio/>").attr("src", key).attr("controls", "controls");
      } else {
        fileName = parseURL(key).fileName;
        elm.addClass("otherfile").text(fileName);
      }
      return fileHTML.append(elm);
    });
  } catch (e) {
    console.log("filehtml error");
  }
  return fileHTML;
};

/*  発言フィードを生成
*/

messageHTML = function(data) {
  var date, datestr, fileHTML;
  date = new Date(data.date);
  datestr = naturalFormatDate(date);
  fileHTML = getFileHTML(data);
  return $("<article class=\"box\">\n  <header>\n    <a rel=\"author\">" + data.name + "</a>\n    <time>" + datestr + "</text>\n  </header>\n  <p class=\"text\">" + (formatMessage(data.text)) + "</p>\n</article>").css("display", "none").append(fileHTML);
};

/*  全消去
*/

clear = function() {
  return $("#posts").html("");
};

/*  アップデート処理
*/

update = function() {
  return lbAjax.update(function(data) {
    return $.each(data, function() {
      return messageHTML(this).prependTo("#posts").show("slow");
    });
  });
};

/*  古いデータを取ってくる
*/

more = function() {
  return lbAjax.more(function(data) {
    data.reverse();
    return $.each(data, function() {
      return messageHTML(this).appendTo("#posts").show("slow");
    });
  });
};

/*  書き込むボタン無効化
*/

disableWriteButton = function() {
  $("#write").attr("disabled", true);
  return $("#write").addClass("disable");
};

/*  書き込むボタン有効化
*/

enableWriteButton = function() {
  $("#write").attr("disabled", false);
  $("#write").removeAttr("disabled");
  return $("#write").removeClass("disable");
};

/*  「書き込む」ボタン押し下げ時
*/

writeButton = function() {
  var files, userName;
  userName = $("#user .name").val();
  disableWriteButton();
  files = $("#text").data("files");
  if (files) {
    lbAjax.upload(files, function(response) {
      console.log(response);
      $("#text").data("files", null).removeClass("attached");
      $("#files").html("");
      return lbAjax.write({
        name: userName,
        date: new Date(),
        text: $("#text").val(),
        file: response
      }, function() {
        return $("#text").val("");
      });
    });
  } else {
    lbAjax.write({
      name: userName,
      date: new Date(),
      text: $("#text").val()
    }, function() {
      return $("#text").val("");
    });
  }
  $.cookie('name', userName, {
    expires: 30
  });
  $('#files').empty();
  return update();
};

$(function() {
  var topBtn;
  $("#write").click(writeButton);
  disableWriteButton();
  $(window).keydown(function(e) {
    if (e.ctrlKey && e.keyCode === 13) {
      if (document.activeElement.id === 'text') {
        if ($("#text").val() !== "") writeButton();
      }
      return event.preventDefault();
    }
  });
  $("#text").bind('keyup change', function() {
    if ($(this).val() === "") {
      return disableWriteButton();
    } else {
      return enableWriteButton();
    }
  }).bind("drop", function(e) {
    var files;
    files = e.originalEvent.dataTransfer.files;
    console.log(files);
    $("#files").html("");
    $.each(files, function() {
      return $("#files").append($("<li/>").text(this.name));
    });
    $(this).data("files", files);
    $(this).addClass("attached");
    e.preventDefault();
    e.stopPropagation();
    return $("#files").show();
  });
  topBtn = $('#goTop');
  topBtn.hide();
  $(window).scroll(function() {
    if ($(this).scrollTop() > 100) {
      return topBtn.fadeIn();
    } else {
      return topBtn.fadeOut();
    }
  });
  topBtn.click(function() {
    $('body,html').animate({
      scrollTop: 0
    }, 500);
    return false;
  });
  $("#text").focus(function() {
    $(this).animate({
      height: "100px"
    });
    return $("#posts").animate({
      "margin-top": "156px"
    });
  });
  $("#text").blur(function() {
    $(this).animate({
      height: "16px"
    });
    return $("#posts").animate({
      "margin-top": "70px"
    });
  });
  $(window).bottom();
  $(window).bind("bottom", function() {
    return more();
  });
  return update();
});
