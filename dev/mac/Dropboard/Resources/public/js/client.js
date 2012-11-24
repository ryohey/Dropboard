var lbAjax = new LBAjax;
var lbNotify = new LBNotify;

/* 発言フィードを生成 */
var messageHTML = function(data) {
	var date = new Date(data.date);
	var datestr = naturalFormatDate(date);
	var fileHTML = $("<div/>").addClass("file");
	if (data.file) {
		try{
			var files = JSON.parse(data.file);
			$.each(files,function(val,key){
				var elm = $("<a/>")
							.attr("target","_blank")
							.attr("href",key);
				if (isImage(key)){
					elm
						.fancybox()
						.append(
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
				.append(formatMessage(data.text))
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

/* 古いデータを取ってくる */
var more = function(){
	lbAjax.more(function(data){
		data.reverse();
		$.each(data,function(){
			messageHTML(this).appendTo("#content").show("slow");
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
	        $("#files").html("");
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

	// 名前のクッキーを焼く
	$.cookie('name', $("#name").val(), {expires: 30});

    // ファイル情報削除
    $('#files').empty();

    update();
}

// onload
$(function(){
	//通知を追加
	lbNotify.elm.appendTo("body");
	lbNotify.setPosition("bottom");

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
	        console.log(files);
	        $("#files").html("");
	        $.each(files,function(){
	        	$("#files").append($("<li/>").text(this.name));
	        });
	        $(this).data("files",files);
	        $(this).addClass("attached");
	        e.preventDefault(); 
	        e.stopPropagation();
	    });

	// クッキー
	$("#name").val($.cookie('name'));

	// goTop
	var topBtn = $('#goTop');   
    topBtn.hide();
    $(window).scroll(function () {
        if ($(this).scrollTop() > 100) {
            topBtn.fadeIn();
        } else {
            topBtn.fadeOut();
        }
    });
    topBtn.click(function () {
        $('body,html').animate({
            scrollTop: 0
        }, 500);
        return false;
    });

    // 投稿フォームを開く
    var slide = $('#input');
    var contents = $('#inputForm');
    //開くボタン
    var openDiv = $('#openButton');
    var openFlag = true;
    var panelSwitch = function() {
        //閉じる
        if (openFlag == true ) {
            slide.stop().animate({'width' : '30px','height' : '20px'}, 300);
            openDiv.stop().animate({'top' : '10px','right' : '15px'}, 300);
            contents.hide();
            openDiv.removeClass("close");
            openFlag = false;
        }
        //開く
        else if (openFlag == false) {
            slide
            	.stop()
            	.animate({
            		'width' : '400px',
            		'height' : '190px'
            	}, 300
            	,function(){
            		contents.show();
            		$("#text").focus();
            	});
            openDiv.stop().animate({'top' : '182px','right' : '390px'}, 300);
            
            openDiv.addClass("close");
            openFlag = true;
        }
    };
    //開くボタンクリックしたら
    $('#openButton').click(function(){
        panelSwitch();
    });
    // 初期状態
    panelSwitch();

    //下まで来たらもっと読み込む
    $(window).bottom();
    $(window).bind("bottom", function() {
    	more();
    });

 	// 更新の設定
    update();
    setInterval(update,5000);
})
