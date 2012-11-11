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
            list.push(JSON.parse(file));
        }
    });
    return list;
};

app.post("/write", function(req, res){
    var data = req.body;
    if (typeof data.name !== undefined && typeof data.date !== undefined && typeof data.text !== undefined){
        fs.writeFile('./data/'+data.name+"「"+data.text+"」"+'.json', JSON.stringify(data), function(err){
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