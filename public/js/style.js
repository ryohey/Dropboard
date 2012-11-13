// onload
$(function(){
	// クッキー
	if ($.cookie('color') != null) {
		$("link").attr("href", $.cookie('color'));
	}
	// カラーセレクタ
	$("#colorSelector ul li").click(function() {
		var css = $(this).attr("style-src");
		$("link").attr("href", css);
		$.cookie('color', css, {expires: 30});
	});
})
