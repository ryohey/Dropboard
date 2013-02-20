/*
	通信部分だけ抜き出したクラス的なやつ
	引数に通信完了時の処理を書く
	lbAjax.read(function(data){
		console.log(data);
	})
	こういう感じで
*/

var MESSAGE_PER_PAGE = 15;

var LBAjax = function(){
	/* 前回読み込んだデータ */
	this.lastData = [];
	var _this = this;

	/* 指定数だけ読み込む */
	this.page = function(success,page,per){
		lbNotify.progress("データ取得中");
		$.getJSON("/timeline",{
			page: page,
			per: per
		}, function(data){
			lbNotify.hide();
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
		lbNotify.progress("送信中");
		$.post("/timeline",data,function(response){
			if (response == "1"){
				lbNotify.hide();
				success()
			}else
				lbNotify.warning("送信に失敗しました");
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

		lbNotify.progress("アップロード中");
	    // XHR で送信
	    $.ajax({
	        url: "/upload",
	        type: "post",
	        data: fd,
	        processData: false,
	        contentType: false,
	        success:function(response){
				lbNotify.hide();
	        	success(response);
	        }
	    });
	};
}
