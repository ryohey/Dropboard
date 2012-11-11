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
						.text(data.date)
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
			//messageHTML(this).prependTo("#content");
			$("#content").prepend(messageHTML(this)).masonry("reload");
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

// Masonry corner stamp
$.Mason.prototype.resize = function(){
	//this._getColomns();
	this._reLayout();
}
$.Mason.prototype._reLayout = function( callback ) {
	var freeCols = this.cols;
	if ( this.options.cornerStampSelector ) {
		var $cornerStamp = this.element.find( this.options.cornerStampSelector ),
		cornerStampX = $cornerStamp.offset().left - 
		( this.element.offset().left + this.offset.x + parseInt($cornerStamp.css('marginLeft')) );
		freeCols = Math.floor( cornerStampX / this.columnWidth );
	}
    // reset columns
    var i = this.cols;
    this.colYs = [];
    while (i--) {
    	this.colYs.push( this.offset.y );
    }

    for ( i = freeCols; i < this.cols; i++ ) {
    	this.colYs[i] = this.offset.y + $cornerStamp.outerHeight(true);
    }

    // apply layout logic to all bricks
    this.layout( this.$bricks, callback );
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
	$("#text").bind('keyup change', function() {
		if ($(this).val() == "") {
			disableWriteButton();
		} else {
			enableWriteButton();
		}
	})

	// masonry
	$("#content").masonry({
		itemSelector: '.box',
		isAnimated: !Modernizr.csstransitions,
		cornerStampSelector: '#input'/*,
		columnWidth: function(containerWidth) { return containerWidth/5; }*/
	});

	// 更新の設定
	update();
	setInterval(update,5000);
})
