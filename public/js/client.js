var contextMenu, lbAjax, lbNotify,
  _this = this;

lbAjax = new LBAjax;

lbNotify = new LBNotify;

contextMenu = function(x, y, title, cancelTitle, okTitle, items, complete) {
  var elm;
  if (!$("#contextMenu").length) $("body").append("<div id='#contextMenu'></div>");
  elm = $("#contextMenu").html("<header>\n  <h3>" + title + "</h3>\n</header>\n<div class=\"content\"></div>\n<footer>\n  <a class=\"cancel button button_gray\">" + cancelTitle + "</a>\n  <a class=\"ok button button_blue\">" + okTitle + "</a>\n</footer>");
  elm.find(".content").append(items);
  elm.find(".ok").click(function() {
    return complete(elm);
  });
  elm.find(".cancel").click(function() {
    return elm.hide();
  });
  elm.css({
    left: x,
    top: y
  }).show();
  elm.find("input:first").focus();
  return elm;
};

$(function() {
  var activePage;
  lbNotify.elm.appendTo("body");
  lbNotify.setPosition("bottom");
  activePage = location.pathname.replace(/^\//, "");
  $("#side nav ul li").find("." + activePage).addClass("active");
  return $("#user .name").val($.cookie('name'));
});
