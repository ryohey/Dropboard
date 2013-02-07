var ArrayQuery;

ArrayQuery = (function() {

  function ArrayQuery(array) {
    if (!(this instanceof ArrayQuery)) return new ArrayQuery(array);
    this.data = array;
  }

  ArrayQuery.prototype.all = function() {
    return this.data;
  };

  ArrayQuery.prototype.sortByDate = function() {
    return this.data.sort(this.createSorter("date", function(a) {
      return (new Date(a)).getTime();
    }));
  };

  ArrayQuery.prototype.createSorter = function(property, func) {
    return function(a, b) {
      return (a ? func(a[property]) : Number.MIN_VALUE) - (b ? func(b[property]) : Number.MIN_VALUE);
    };
  };

  ArrayQuery.prototype.page = function(page, per) {
    var end, start;
    start = Math.max(this.data.length - (page + 1) * per, 0);
    end = Math.max(this.data.length - page * per, 0);
    return this.data.slice(start, end);
  };

  return ArrayQuery;

})();

module.exports = ArrayQuery;
