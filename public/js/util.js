/*
	特定のHTMLやURLに関係しないコード
*/

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

/* テキスト中の特定の文字列をフォーマット */
var formatMessage = function(str){
	/* twitter風 */
	var hashPattern = /(?:^|[^ｦ-ﾟー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9&_\/]+)[#＃]([ｦ-ﾟー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9_]*[ｦ-ﾟー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z]+[ｦ-ﾟー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9_]*)/gm;
	var urlPattern = /(https?:\/\/[a-zA-Z0-9;\/?:@&=\+$,\-_\.!~*'\(\)%#]+)/gm;

	var h = function(str){
		return $("<div/>").text(str).html();
	}

	var replaceURL = function(str){
		//タグの中に入ってないURLだけ変えたい
		var urls = str.match(urlPattern);
		if (urls){
			$.each(urls,function(index,value){
				if (!isYoutubeDomain(value) && !isTwitter(value))
					str = str.replace(value,'<a href="'+value+'" target="_blank">'+value+'</a>');
			});
		}
		return str;
	}

	var replaceTwitter = function(str) {
		str = ' ' + str;
		str = str.replace(/([^\w])\@([\w\-]+)/gm,'$1@<a href="http://twitter.com/$2" target="_blank">$2</a>');
		str = str.replace(hashPattern,' <a href="http://twitter.com/search?q=%23$2" target="_blank">#$1</a>');
		return str;
	}

	/* youtube対応　*/
	var replaceYoutube = function(str){
		var urls = str.match(urlPattern);
		var iframes = [];
		if (urls){
			$.each(urls,function(index,value){
				if (isYoutube(value)){
					var src = value.replace(youtubeExp,"http\:\/\/www\.youtube\.com\/embed\/$1");
					var elm = 
					$("<div/>")
						.addClass("video")
						.append(
							$("<iframe/>")
								.attr({
									"width":"640",
									"height":"360",
									"src":src,
									"frameborder":"0",
									"allowfullscreen":"true"
								})
						);
					iframes.push({
						"url" : value,
						"html" : elm.wrap('<div>').parent().html()
					});
				}
			});
			$.each(iframes,function(index,value){
				str = str.replace(value.url, value.html);
			});
		}
		return str;
	}

	return　replaceURL(
				replaceTwitter(
					replaceYoutube(
						h(str)
					)
				)
			);
}

var parseURL = function(url) {
	var data, hostname, scheme, slashes;
	slashes = url.split("/");
	data = {};
	if (slashes.length > 0) {
	  scheme = slashes[0].match(/.+?:/);
	  data.scheme = scheme != null ? scheme[0].replace(":", "") : void 0;
	  hostname = url.replace(data.scheme + ":\/\/", "").match(/^.+?\//);
	  data.hostname = hostname != null ? hostname[0].replace(/\//, "") : void 0;
	  if (!url.match(/\/$/)) {
	    data.fileName = slashes[slashes.length - 1];
	    data.extension = data.fileName.replace(/^.+?\./, "");
	  }
	}
	return data;
}

var isFileType = function(file,extensions){
	var ext = parseURL(file).extension;
	var flag = false;
    $.each(extensions, function(val,key){
        if (ext == key || ext == key.toUpperCase()){
            flag = true;
            return false; //breakの代わり
        }
    });
    return flag;
}

var isImage = function(file){
    return isFileType(file,["jpg", "jpeg","png","gif"]);
}

var isAudio = function(file){
	return isFileType(file,["mp3","ogg","wav"]);
}

var youtubeDomainExp = /https?\:\/\/www\.youtube\.com.*/gm;
var isYoutubeDomain = function(url){
	if (url.match(youtubeDomainExp))
		return true;
	else
		return false;
}

var youtubeExp = /https?\:\/\/www\.youtube\.com\/watch\?v\=([a-zA-Z0-9]+).*/gm;
var isYoutube = function(url){
	if (url.match(youtubeExp))
		return true;
	else
		return false;
}

var twitterExp = /https?\:\/\/twitter\.com.*/gm;
var isTwitter = function(url){
	if (url.match(twitterExp))
		return true;
	else
		return false;
}

// 日付関係
var to2keta = function(val) {
    return (val < 10) ? '0'+val : val;
}

var naturalFormatDate = function(date) {
    return date.getFullYear() + "/" + to2keta(date.getMonth()) + "/" + to2keta(date.getDate()) + " " + to2keta(date.getHours()) + ":" + to2keta(date.getMinutes());
}
