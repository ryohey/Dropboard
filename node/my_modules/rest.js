var Reader, Rest;

Reader = require("./reader");

Rest = (function() {

  function Rest(name) {
    this.route = "/" + name;
    this.dataPath = "data/" + name + "/";
    this.reader = new Reader(this.dataPath);
  }

  Rest.prototype.bind = function(app) {
    app.post(this.route, this.post);
    app.put(this.route, this.put);
    app.get(this.route, this.get);
    return app["delete"](this.route, this["delete"]);
  };

  Rest.prototype.post = function(req, res) {
    return res.send(501, "Not Implemented");
  };

  Rest.prototype.put = function(req, res) {
    return res.send(501, "Not Implemented");
  };

  Rest.prototype.get = function(req, res) {
    return res.send(501, "Not Implemented");
  };

  Rest.prototype["delete"] = function(req, res) {
    return res.send(501, "Not Implemented");
  };

  return Rest;

})();

module.exports = Rest;
