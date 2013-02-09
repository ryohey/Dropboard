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

  viewDisplay : (view) =>
    $.ajax {
      url: "/calendar"
      dataType: 'json'
      type: "get"
      data: {
        "start": view.start.toString()
        "end": view.end.toString()
      }
      success: (EventSource) =>
        @fc.removeEvents
        @fc.addEventSource EventSource
    }

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
        <li><input type="checkbox" class="allDay" value="allDay" #{if event.allDay or @isLongEvent then "checked" else ""} #{if @isLongEvent(event) then "disabled" else ""}>終日</li>
        <li class="range">開始<input type="text" class="start" value="#{start}"></li>
        <li class="range">終了<input type="text" class="end" value="#{end}"></li>
        <li><a class="delete button button_red">削除</a></li>
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

    contextMenu jsEvent.pageX, jsEvent.pageY, "イベントの編集", "キャンセル", "決定", items, (elm) =>
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
        <li>タイトル<input type="text" class="title" value=""></li>
      </ul>
    """)
    contextMenu jsEvent.pageX, jsEvent.pageY, "イベントの追加", "キャンセル", "決定", items, (elm) =>
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
      titleFormat: {
        month: 'yyyy年 M月'
        week: '[yyyy年 ]M月 d日{ &#8212;[yyyy年 ][ M月] d日}'
        day: 'yyyy年 M月 d日 dddd'
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
      allDayText: "終日"
      axisFormat: 'H:mm'
      dayNames: ['日曜日','月曜日','火曜日','水曜日','木曜日','金曜日','土曜日']
      dayNamesShort: ['日','月','火','水','木','金','土']
      buttonText: {
        prev: '&nbsp;&#9668;&nbsp;'
        next: '&nbsp;&#9658;&nbsp;'
        prevYear: '&nbsp;&lt;&lt;&nbsp;'
        nextYear: '&nbsp;&gt;&gt;&nbsp;'
        today: '今日'
        month: '月'
        week: '週'
        day: '日'
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

$(() ->
  calendar = new MyCalendar()

  # auto update
  socket = io.connect('http://localhost')
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
)