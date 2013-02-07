class ArrayQuery
  constructor : (array) ->
    unless this instanceof ArrayQuery
      return new ArrayQuery(array)
    @data = array

  all : () ->
    @data

  sortByDate : () ->
    @data.sort(@createSorter("date", (a) ->
      (new Date(a)).getTime()
    ))

  createSorter : (property, func) ->
    (a, b) ->
      (if a then func(a[property]) else Number.MIN_VALUE) - 
      (if b then func(b[property]) else Number.MIN_VALUE)

  page : (page, per) ->
    start = Math.max(@data.length - (page+1)*per, 0)
    end = Math.max(@data.length - page*per,0)
    @data.slice(start,end)  #新しいやつからとってくる

module.exports = ArrayQuery