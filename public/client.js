var sortByDate = function(a, b){
    if (!a)
        return -1;
    else if (!b)
        return 1;
    var ax = (new Date(a.date)).getTime();
    var bx = (new Date(b.date)).getTime();
    ax = ax?ax:0;
    bx = bx?bx:0;
    return bx - ax;
}

var read = function(){
	$.get("/read",function(response){
		var data = $.parseJSON(response);
		data.sort(sortByDate);
		$.each(data,function(){
			$("<article/>")
				.append(
					$("<header/>")
						.append(
							$("<a/>")
								.attr("rel","author")
								.text(this.name)
						)
						.append(
							$("<time/>")
								.text(this.date)
						)
				)
				.append(
					$("<div/>")
						.addClass("content")
						.text(this.text)
				)
				.appendTo("#content")
		})
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
	clear();
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
	enableWriteButton();
}

$(function(){
	// 「書き込むボタン」
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
	update();
	setInterval(update,5000);
})
