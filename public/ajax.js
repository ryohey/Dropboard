/*
	通信部分だけ抜き出したクラス的なやつ
	引数に通信完了時の処理を書く
	lbAjax.read(function(data){
		console.log(data);
	})
	こういう感じで
*/

var LBAjax = function(){
	/* 前回読み込んだデータ */
	this.lastData = [];
	var _this = this;

	/* すべてのデータを読み込む */
	this.read = function(success){
		$.get("/read",function(response){
			var data = $.parseJSON(response);
			success(data);
		})
	}

	/* 最新のデータを取り出す */
	this.update = function(success){
		var _success = success;
		_this.read(function(data){
			var diff = messageDiff(_this.lastData,data);
			diff.sort(sortByDate);
			_success(diff);
			_this.lastData = data;
		})
	}

	/* 書き込む */
	this.write = function(data,success){
		$.post("/write",data,function(response){
			if (response == "1")
				success()
		})
	}

	/* アップロードする */
	this.upload = function (files,success) {
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
}