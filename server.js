var express = require('express'),
         fs = require('fs');

var app = express();

app.use(require('connect').bodyParser());

app.post("/write", function(req, res){
    var data;
    try{
        var file = fs.readFileSync('./data.json');
        data = JSON.parse(file);
    }catch(e){
        console.log(e);
        data = [];
    }
    console.log(data,req.body);
    if (typeof req.body.name !== undefined && typeof req.body.date !== undefined && typeof req.body.text !== undefined){
        data.push(req.body);
        fs.writeFile('./data.json', JSON.stringify(data), function(err){
            if (err)
                res.send("0");
            else
                res.send("1");
        });
    }
})

app.get('/read', function(req, res){
    res.send(fs.readFileSync('./data.json'));
});

app.use("/",express.static(__dirname + '/public'));

app.listen(3141);