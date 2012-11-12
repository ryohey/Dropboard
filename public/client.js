var sortByDate = function(a, b){
    if (!a)
        return -1;
    else if (!b)
        return 1;
    var ax = (new Date(a.date)).getTime();
    var bx = (new Date(b.date)).getTime();
    ax = ax?ax:0;
    bx = bx?bx:0;
    return ax - bx;
}

var messageDiff = function(before,after){
	var added = [];
	var isExist = function(that){
		var flag = false;
		$.each(before, function(){
			if (this.date == that.date && this.text == that.text && this.name == that.name){
				flag = true;
				return;
			}
		})
		return flag;
	}
	$.each(after,function(){
		if (!isExist(this))
			added.push(this);
	})
	return added;
}

/* twitter風 */
var hashPattern = /(?:^|[^ｦ-ﾟー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9&_\/]+)[#＃]([ｦ-ﾟー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9_]*[ｦ-ﾟー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z]+[ｦ-ﾟー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9_]*)/gm;
var urlPattern = /(https?:\/\/[a-zA-Z0-9;\/?:@&=\+$,\-_\.!~*'\(\)%#]+)/gm;
var formatTwitString = function(str) {
	str=' '+str;
	str = str.replace(urlPattern,'<a href="$1" target="_blank">$1</a>');
	str = str.replace(/([^\w])\@([\w\-]+)/gm,'$1@<a href="http://twitter.com/$2" target="_blank">$2</a>');
	str = str.replace(hashPattern,'<a href="http://twitter.com/search?q=%23$2" target="_blank">#$1</a>');
	return str;
}

/* 発言フィードを生成 */
var messageHTML = function(data) {
	// エスケープ用要素
	var date = new Date(data.date);
	var datestr = date.getFullYear() + "/" + date.getMonth() + "/" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes();
	var target =  $("<article/>")
	    .addClass("box")
	    .css("display", "none")
		.append(
			$("<header/>")
				.append(
					$("<a/>")
						.attr("rel","author")
						.text(data.name)
				)
				.append(
					$("<time/>")
						.text(datestr)
				)
		)
		.append(
			$("<p/>")
				.append(formatTwitString($("<div/>").text(data.text).html()))
		);
	return target;
}

/* 最新の投稿? */
var lastData = [];

/* 読み込む */
var read = function(){
	$.get("/read",function(response){
		var data = $.parseJSON(response);
		var diff = messageDiff(lastData,data);
		console.log(diff);
		diff.sort(sortByDate);
		$.each(diff,function(){
			messageHTML(this).prependTo("#content").show("slow");
		})
		lastData = data;
	})
}

/* 書き込む */
var write = function(name,date,text){
	$.post("/write",{
		"name":name,
		"date":date,
		"text":text
	},function(response){
		console.log(response);
		if (response == "1")
			$("#text").val("");
		update();
	})
}

/* 全消去 */
var clear = function(){
	$("#content").html("");
}

/* アップデート処理 */
var update = function(){
	read();
}

/* 書き込むボタン無効化 */
var disableWriteButton = function() {
	$("#write").attr("disabled", true);
	$("#write").addClass("disable");
}

/* 書き込むボタン有効化 */
var enableWriteButton = function() {
	$("#write").attr("disabled", false);
	$("#write").removeAttr("disabled");
	$("#write").removeClass("disable");
}

/* 「書き込む」ボタン押し下げ時 */
var writeButton = function() {
	disableWriteButton();
	write($("#name").val(),new Date(),$("#text").val());
	update();
}

// onload
$(function(){
	// 「書き込む」ボタン
	$("#write").click(writeButton);
	disableWriteButton();
	
	// Ctrl+Enterで送信
	$(window).keydown( function(e) {
		if (e.ctrlKey && e.keyCode == 13)  {
			if (document.activeElement.id == 'text') {
				if ($("#text").val() != "") {
					writeButton();
				}
			}
			event.preventDefault();
		}
	});
	
	// textareaの監視
	$("#text").bind('keyup change', function() {
		if ($(this).val() == "") {
			disableWriteButton();
		} else {
			enableWriteButton();
		}
	})

	// 更新の設定
	update();
	setInterval(update,5000);
})
