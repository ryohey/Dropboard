var express = require('express'),
         fs = require('fs');

var app = express();

app.use(require('connect').bodyParser());

var getFiles = function(dataPath){
    var files = fs.readdirSync(dataPath);
    var list = [];
    files.forEach(function(fileName){
        if (fileName.match(/.+\.json/)){
            var file = fs.readFileSync(dataPath+fileName);
            var data = null;
            try{
                data = JSON.parse(file)
            }catch(e){
                console.log(e)
            }
            if (data)
                list.push(data);
        }
    });
    return list;
};

var isSet = function(arg){
    if (typeof arg !== undefined)
        if (arg !== "")
            return true;
    return false;
}

var shorten = function(str,length){
    var s = str.replace(/\n|\\|\/|\:|\*|\?|\"|\<|\>|\|/g,"");
    var postfix = "...";
    if (s.length > length)
        if (length > postfix.length)
            return s.slice(0,length-postfix.length)+postfix;
        else
            return s.slice(0,length);
    else
        return s;
        
}

app.post("/write", function(req, res){
    var data = req.body;
    if (isSet(data.name) && isSet(data.date) && isSet(data.text)){
        fs.writeFile('./data/'+shorten(data.name,10)+"「"+shorten(data.text,20)+"」"+'.json', JSON.stringify(data), function(err){
            if (err)
                res.send("0");
            else
                res.send("1");
        });
    }
})

app.get('/read', function(req, res){
    res.send(JSON.stringify(getFiles('./data/')));
});

app.use("/",express.static(__dirname + '/public'));

app.listen(3141);