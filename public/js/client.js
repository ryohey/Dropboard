var lbAjax, lbNotify;

lbAjax = new LBAjax;

lbNotify = new LBNotify;

$(function() {
  var activePage;
  lbNotify.elm.appendTo("body");
  lbNotify.setPosition("bottom");
  activePage = location.pathname.replace(/^\//, "");
  return $("#side nav ul li").find("." + activePage).addClass("active");
});
