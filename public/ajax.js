/*
	通信部分だけ抜き出した
*/

var LocalBoardAjax = function(){
	/* 前回読み込んだデータ */
	this.lastData = [];

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
		this.read(function(data){
			var diff = messageDiff(lastData,data);
			console.log(diff);
			diff.sort(sortByDate);
			_success(diff);
			lastData = data;
		})
	}

	/* 書き込む */
	this.write = function(data,success){
		$.post("/write",data,function(response){
			console.log(response);
			if (response == "1")
				success()
		})
	}
}
/*
var localBoardAjax = new LocalBoardAjax;

update(function(data){
	$.each(data,function(){
		messageHTML(this).prependTo("#content").show("slow");
	})
})

write({
	name:
	date:
	text:
	file:
},function(){
	update();
})*/