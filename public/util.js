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

/* twitter風 */
var hashPattern = /(?:^|[^ｦ-ﾟー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9&_\/]+)[#＃]([ｦ-ﾟー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9_]*[ｦ-ﾟー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z]+[ｦ-ﾟー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9_]*)/gm;
var urlPattern = /(https?:\/\/[a-zA-Z0-9;\/?:@&=\+$,\-_\.!~*'\(\)%#]+)/gm;
var formatTwitString = function(str) {
	str=' '+str;
	str = str.replace(urlPattern,'<a href="$1" target="_blank">$1</a>');
	str = str.replace(/([^\w])\@([\w\-]+)/gm,'$1@<a href="http://twitter.com/$2" target="_blank">$2</a>');
	str = str.replace(hashPattern,'<a href="http://twitter.com/search?q=%23$2" target="_blank">#$1</a>');
	return str;
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