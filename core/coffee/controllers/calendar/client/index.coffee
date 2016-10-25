$ = require "jQuery"
contextMenu = require "../../../components/context-menu.coffee"
require "./style.sass"

class MyCalendar
  constructor : () ->
    $.getJSON "calendar", (events) =>
      @elm = @createFullCalendar(events)
      @fc = @elm.data("fullCalendar")

  isLongEvent : (event) =>
    if event.start? and event.end?
      (formatDate(event.start, "yyyyMMdd") != formatDate(event.end, "yyyyMMdd"))
    else
      false

  ### fullcalendar callbacks ###
  eventResize : (event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view) =>
    if @isLongEvent(event)
      event.allDay = true
    @updateEvent event

  ##サーバに送るときに使う
  eventData : (event) ->
    {
      title: event.title
      start: event.start
      end: event.end
      allDay: event.allDay
      _id: event._id
    }

  removeEvent : (event, complete, error) =>
    $.ajax {
      url: '/calendar'
      type: 'delete'
      data:  @eventData(event)
      success: (res) =>
        @fc.removeEvents event._id
        complete?(res)
      error: (res) =>
        error?(res)
    }

  updateEvent : (event, complete, error) =>
    $.ajax {
      url: '/calendar'
      type: 'put'
      data:  @eventData(event)
      success: (res) =>
        @fc.updateEvent event
        complete?(res)
      error: (res) =>
        error?(res)
    }

  eventDrop : (event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view) =>
    @updateEvent event

  eventClick : (event, jsEvent, view) =>
    console.log event._id
    start = formatDate(event.start, "HH:mm")
    if event.end?
      end = formatDate(event.end, "HH:mm")
    else
      end = "00:00"

    items = $("""
      <ul class="inputs">
        <li>タイトル<input type="text" class="title" value="#{event.title}"></li>
        <li><input type="checkbox" class="allDay" value="allDay" #{if event.allDay or @isLongEvent(event) then "checked" else ""} #{if @isLongEvent(event) then "disabled" else ""}>All day</li>
        <li class="range">Start<input type="text" class="start" value="#{start}"></li>
        <li class="range">End<input type="text" class="end" value="#{end}"></li>
        <li><a class="delete button button_red">Delete</a></li>
      </ul>
    """)
    
    showRange = () =>
      unless items.find(".allDay").attr("checked")
        items.find(".range").show()
      else
        items.find(".range").hide()

    items.find(".allDay").change showRange
    showRange()

    items.find(".delete").click () =>
      $("#contextMenu").hide()
      @removeEvent event

    contextMenu jsEvent.pageX, jsEvent.pageY, "Edit the event", "Cancel", "OK", items, (elm) =>
      elm.hide()
      event.title = elm.find(".title").val()
      hourExp = /([0-9]+)[\:：\s\,]([0-9]+)/
      allDay = items.find(".allDay").attr("checked")
      unless allDay
        event.allDay = false
        startArr = elm.find(".start").val().match hourExp
        if startArr.length == 3
          event.start.setHours(startArr[1])
          event.start.setMinutes(startArr[2])
        endArr = elm.find(".end").val().match hourExp
        if endArr.length == 3
          unless event.end then event.end = new Date(event.start)
          event.end.setHours(endArr[1])
          event.end.setMinutes(endArr[2])
      else
        event.allDay = true
      @updateEvent event

  select : (start, end, allDay, jsEvent, view) =>
    items = $("""
      <ul class="inputs">
        <li>Title<input type="text" class="title" value=""></li>
      </ul>
    """)
    contextMenu jsEvent.pageX, jsEvent.pageY, "Create an event", "Cancel", "OK", items, (elm) =>
      elm.hide()
      title = elm.find(".title").val()
      if (title) 
        event = {
          title: title
          start: start
          end: end
          allDay: allDay
        }
        @fc.renderEvent event, true
        console.log "added id:"+event._id
        @fc.removeEvents event._id
        $.post "calendar", @eventData(event), (res) =>

  ### ###
  createFullCalendar : (events) =>
    console.log events
    $('#calendar').fullCalendar {
      header: {
        left: 'prev,next today'
        center: 'title'
        right: 'month,agendaWeek,agendaDay'
      }
      columnFormat: {
        month: 'ddd'
        week: 'M/d（ddd）'
        day: 'M/d（ddd）'
      }
      timeFormat: {
        '': 'H:mm'
        agenda: 'H:mm{ - H:mm}'
      }
      axisFormat: 'H:mm'
      buttonText: {
        prev: '&nbsp;&#9668;&nbsp;'
        next: '&nbsp;&#9658;&nbsp;'
        prevYear: '&nbsp;&lt;&lt;&nbsp;'
        nextYear: '&nbsp;&gt;&gt;&nbsp;'
      }
      selectable: true
      editable: true
      selectHelper: true
      eventDrop: @eventDrop
      events: "/calendar"
      #viewDisplay: viewDisplay
      select: @select
      eventClick: @eventClick
      eventResize: @eventResize
    }

module.exports = (path) ->
  return unless path is"/calendar"
  calendar = new MyCalendar()

  # auto update
  socket = io.connect(location.origin)
  socket.on 'update', () ->
    calendar.fc.refetchEvents()

  $(window).keydown (e) ->
    #  Ctrl+Enterで決定
    if e.ctrlKey and e.keyCode == 13
      if $("#contextMenu").is(':visible')
        $("#contextMenu .ok").click()

    #  Escでフォーカスを外す
    if e.keyCode == 27
      $("#contextMenu").hide()
