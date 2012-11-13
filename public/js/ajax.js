/*
	通信部分だけ抜き出したクラス的なやつ
	引数に通信完了時の処理を書く
	lbAjax.read(function(data){
		console.log(data);
	})
	こういう感じで
*/

var MESSAGE_PER_PAGE = 20;

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

	/* 指定数だけ読み込む */
	this.page = function(success,page,per){
		$.get("/page/"+page+"/"+per,function(response){
			var data = $.parseJSON(response);
			success(data);
		})
	}

	/* 差分を取得 */
	this._diff = function(success,page,per){
		var _success = success;
		_this.page(function(data){
			var diff = messageDiff(_this.lastData,data);
			diff.sort(sortByDate);
			_success(diff);
			_this.lastData = _this.lastData.concat(diff);
		},page,per)
	}

	/* 最新のデータを取り出す */
	this.update = function(success){
		this._diff(success,0,MESSAGE_PER_PAGE);
	}

	/* 過去のデータを取り出す */
	this.more = function(success){
		this._diff(success,Math.floor(_this.lastData.length/MESSAGE_PER_PAGE),MESSAGE_PER_PAGE);
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
