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
		$("#write").removeClass("disable");
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

$(function(){
	$("#write").click(function(){
		$(this).addClass("disable");
		write($("#name").val(),new Date(),$("#text").val());
	})
	update();
	setInterval(update,5000);
})
