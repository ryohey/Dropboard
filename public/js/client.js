var clear, disableWriteButton, enableWriteButton, getFileHTML, lbAjax, lbNotify, messageHTML, more, update, writeButton;

lbAjax = new LBAjax;

lbNotify = new LBNotify;

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
  return $("<article class=\"box\">\n  <header>\n    <a rel=\"author\">" + data.name + "</a>\n    <time>" + datestr + "</text>\n  </header>\n  <p class=\"text\">" + (formatMessage(data.text)) + "</p>\n  " + fileHTML + "\n</article>").css("display", "none");
};

/*  全消去
*/

clear = function() {
  return $("#content").html("");
};

/*  アップデート処理
*/

update = function() {
  return lbAjax.update(function(data) {
    return $.each(data, function() {
      return messageHTML(this).prependTo("#content").show("slow");
    });
  });
};

/*  古いデータを取ってくる
*/

more = function() {
  return lbAjax.more(function(data) {
    data.reverse();
    return $.each(data, function() {
      return messageHTML(this).appendTo("#content").show("slow");
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
  var files;
  disableWriteButton();
  files = $("#text").data("files");
  if (files) {
    lbAjax.upload(files, function(response) {
      console.log(response);
      $("#text").data("files", null).removeClass("attached");
      $("#files").html("");
      return lbAjax.write({
        name: $("#name").val(),
        date: new Date(),
        text: $("#text").val(),
        file: response
      }, function() {
        return $("#text").val("");
      });
    });
  } else {
    lbAjax.write({
      name: $("#name").val(),
      date: new Date(),
      text: $("#text").val()
    }, function() {
      return $("#text").val("");
    });
  }
  $.cookie('name', $("#name").val(), {
    expires: 30
  });
  $('#files').empty();
  return update();
};

$(function() {
  var contents, openDiv, openFlag, panelSwitch, slide, topBtn;
  lbNotify.elm.appendTo("body");
  lbNotify.setPosition("bottom");
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
    return e.stopPropagation();
  });
  $("#name").val($.cookie('name'));
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
  slide = $('#input');
  contents = $('#inputForm');
  openDiv = $('#openButton');
  openFlag = true;
  panelSwitch = function() {
    if (openFlag === true) {
      slide.stop().animate({
        'width': '30px',
        'height': '20px'
      }, 300);
      openDiv.stop().animate({
        'top': '10px',
        'right': '15px'
      }, 300);
      contents.hide();
      openDiv.removeClass("close");
      return openFlag = false;
    } else if (openFlag === false) {
      slide.stop().animate({
        'width': '400px',
        'height': '190px'
      }, 300, function() {
        contents.show();
        return $("#text").focus();
      });
      openDiv.stop().animate({
        'top': '182px',
        'right': '390px'
      }, 300);
      openDiv.addClass("close");
      return openFlag = true;
    }
  };
  $('#openButton').click(function() {
    return panelSwitch();
  });
  panelSwitch();
  $(window).bottom();
  $(window).bind("bottom", function() {
    return more();
  });
  return update();
});
