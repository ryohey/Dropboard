/*
	ポップアップ
*/

NOTIFY_MIN_TIME = 500;		//閉じる最短時間
var LBNotify = function(){
	this.elm = $("<div/>")
		.attr("id","lbNotify"+$(".lbNotify").length)
		.addClass("lbNotify")
		.append(
			$("<div/>")
				.addClass("inner")
		);
	this.timer = null;
	this.lastShow = 0;
	_this = this;
	this._show = function(message,className){
		_this.lastShow = new Date();
		_this.elm.find(".inner").text(message);
		_this.elm
			.removeClass("notice,progress,warning")
			.addClass(className)
			.stop()
			.animate({
				"opacity":"1"
			},400);
	}
	this._setWillHide = function(time){
		if (_this.timer != null)
			clearTimeout(_this.timer);
		_this.timer = setTimeout(function(){
			_this.hide();
		},time);
	}
	//ただのメッセージ
	this.notice = function(message){
		_this._show(message,"notice");
		_this._setWillHide(2000);
	}
	//ぐるぐる付き
	this.progress = function(message){
		_this._show(message,"progress");
	}
	//赤い
	this.warning = function(message){
		_this._show(message,"warning");
		_this._setWillHide(2000);
	}
	//閉じる
	this.hide = function(){
		var interval = new Date() - _this.lastShow;
		if (interval > NOTIFY_MIN_TIME)
			_this.elm
				.stop()
				.animate({
					"opacity":"0"
				},400);
		else
			_this._setWillHide(NOTIFY_MIN_TIME-interval);

	}
	//表示位置の設定
	this.setPosition = function(position){
		if (position == "top")
			_this.elm.css({
				"top":"0",
				"left":"0"
			})
		else if (position == "bottom")
			_this.elm.css({
				"bottom":"0",
				"left":"0"
			})
	}
}