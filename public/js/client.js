var lbAjax = new LBAjax;

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

/* 全消去 */
var clear = function(){
	$("#content").html("");
}

/* アップデート処理 */
var update = function(){
	lbAjax.update(function(data){
		$.each(data,function(){
			messageHTML(this).prependTo("#content").show("slow");
		})
	})
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
		lbAjax.upload(files,function(response){
			console.log(response);
			$("#text")
				.data("files",null)
	        	.removeClass("attached");
			lbAjax.write({
				name:$("#name").val(),
				date:new Date(),
				text:$("#text").val(),
				file:response
			},function(){
				$("#text").val("");
			});
		});
	else
		lbAjax.write({
			name:$("#name").val(),
			date:new Date(),
			text:$("#text").val()
		},function(){
			$("#text").val("");
		});
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
		$("link").attr("href", "css/white.css");
	});
	$(".colorBlack").click(function() {
		$("link").attr("href", "css/black.css");
	});

	// 更新の設定
	update();
	setInterval(update,5000);
})
