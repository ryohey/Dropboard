/* 発言フィードを生成 */
var messageHTML = function(data) {
	var date = new Date(data.date);
	var datestr = date.getFullYear() + "/" + date.getMonth() + "/" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes();
	var fileHTML = $("<div/>").addClass("file");
	if (data.file)
		try{
			var files = JSON.parse(data.file);
			$.each(files,function(val,key){
				var elm = $("<a/>")
							.attr("target","_blank")
							.attr("href",key);
				if (isImage(key)){
					elm.append(
						$("<img/>").attr("src",key)
					)
				}else if (isAudio(key)){
					//リンクはいらないのでelmを上書き
					elm = $("<audio/>")
						.attr("src",key)
						.attr("controls","controls");
				}else{
					var fileName = parseURL(key).fileName;
					elm.addClass("otherfile").text(fileName);
				}
				fileHTML.append(elm);
			})
		}catch(e){

		}
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
				.append(fileHTML)
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
var write = function(name,date,text,file){
	$.post("/write",{
		"name":name,
		"date":date,
		"text":text,
		"file":file
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
	var files = $("#text").data("files");
	if (files)
		uploadFiles(files,function(response){
			$("#text")
				.data("files",null)
	        	.removeClass("attached")
			console.log(response);
			write($("#name").val(),new Date(),$("#text").val(),response);
		});
	else
		write($("#name").val(),new Date(),$("#text").val());
	update();
}

var uploadFiles = function (files,success) {
    // FormData オブジェクトを用意
    var fd = new FormData();

    // ファイル情報を追加する
    for (var i = 0; i < files.length; i++) {
        fd.append("files", files[i]);
    }

    // XHR で送信
    $.ajax({
        url: "/upload",
        type: "POST",
        data: fd,
        processData: false,
        contentType: false,
        success:success
    });
};

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
	$("#text")
		.bind('keyup change', function() {
			if ($(this).val() == "") {
				disableWriteButton();
			} else {
				enableWriteButton();
			}
		})
		.bind("drop", function (e) {
	        // ドラッグされたファイル情報を取得
	        var files = e.originalEvent.dataTransfer.files;
	        $(this).data("files",files);
	        $(this).addClass("attached");
	        e.preventDefault(); 
	        e.stopPropagation();
	    });

	// カラーセレクタ
	$(".colorWhite").click(function() {
		$("link").attr("href", "white.css");
	});
	$(".colorBlack").click(function() {
		$("link").attr("href", "black.css");
	});

	// 更新の設定
	update();
	setInterval(update,5000);
})
