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

var messageHTML = function(data){
	var date = new Date(data.date);
	var datestr = date.getFullYear() + "/" + date.getMonth() + "/" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes();
	return $("<article/>")
	    .addClass("box")
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
				.text(data.text)
		)
}

var lastData = [];

var read = function(){
	$.get("/read",function(response){
		var data = $.parseJSON(response);
		var diff = messageDiff(lastData,data);
		console.log(diff);
		diff.sort(sortByDate);
		$.each(diff,function(){
			messageHTML(this).prependTo("#content");
		})
		lastData = data;
	})
}

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

var clear = function(){
	$("#content").html("");
}

var update = function(){
	read();
}

var disableWriteButton = function() {
	$("#write").attr("disabled", true);
	$("#write").addClass("disable");
}

var enableWriteButton = function() {
	$("#write").attr("disabled", false);
	$("#write").removeAttr("disabled");
	$("#write").removeClass("disable");
}

// 「書き込む」ボタン押し下げ時
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
