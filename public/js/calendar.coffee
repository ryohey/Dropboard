$(() ->
  contextMenu = (x, y, title, cancelTitle, okTitle, items, complete) ->
    elm = $("#contextMenu")
      .html("""
        <header>
          <h3>#{title}</h3>
        </header>
        <div class="content"></div>
        <footer>
          <a class="cancel">#{cancelTitle}</a>
          <a class="ok">#{okTitle}</a>
        </footer>
      """)
    elm.find(".content").append(items)
    elm.find(".ok").click () ->
      complete(elm)
    elm.find(".cancel").click () ->
      elm.hide()
    elm
      .css({
        left: x
        top: y
      })
      .show()
    elm.find("input:first").focus()
    elm

  $.getJSON "calendar", (events) ->
    calendar = $('#calendar').fullCalendar({
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
      ###viewDisplay: (view) ->
        $.ajax({
            url: "/calendar",
            dataType: 'json',
            type: "get",
            data: {
                "start": view.start.toString(),
                "end": view.end.toString(),
            },
            success: (EventSource) ->
                $('#calendar').fullCalendar('removeEvents');
                $('#calendar').fullCalendar('addEventSource', EventSource);
            }
        })###
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
      events: events
      dayClick: (date, allDay, jsEvent, view) ->
        false
      eventClick: (event, jsEvent, view) ->
        console.log event
        start = formatDate(event.start, "HH:mm")
        if event.end
          end = formatDate(event.end, "HH:mm")
        else
          end = "00:00"
        items = $("""
          <ul class="inputs">
            <li>タイトル<input type="text" class="title" value="#{event.title}"></li>
            <li><input type="checkbox" class="allDay" value="allDay" #{if event.allDay then "checked" else ""}>終日</li>
            <li class="range">開始<input type="text" class="start" value="#{start}"></li>
            <li class="range">終了<input type="text" class="end" value="#{end}"></li>
            <li><a class="delete">削除</a></li>
          </ul>
        """)
        
        showRange = () ->
          unless items.find(".allDay").attr("checked")
            items.find(".range").show()
          else
            items.find(".range").hide()

        items.find(".allDay").change showRange
        showRange()
        items.find(".delete").click () ->
          calendar.fullCalendar("removeEvents", event._id)
          $("#contextMenu").hide()
          
        contextMenu jsEvent.pageX, jsEvent.pageY, "イベントの編集", "キャンセル", "決定", items, (elm) ->
          elm.hide()
          event.title = elm.find(".title").val()
          hourExp = /([0-9]+)[\:：\s\,]([0-9]+)/
          unless items.find(".allDay").attr("checked")
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
          calendar.fullCalendar("updateEvent", event)

      reportSelection: () ->
        false
      daySelectionMousedown: () ->
        false
      eventDrop: (event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view) ->
        false
      eventResize: (event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view) ->
        false
      unselect: () ->
        false
      select: (start, end, allDay, jsEvent, view) ->
        console.log arguments
        items = $("""
          <ul class="inputs">
            <li>タイトル<input type="text" class="title" value=""></li>
          </ul>
        """)
        contextMenu jsEvent.pageX, jsEvent.pageY, "イベントの追加", "キャンセル", "決定", items, (elm) ->
          elm.hide()
          console.log elm.find(".title")
          title = elm.find(".title").val()
          if (title) 
            data = {
              title: title,
              start: start,
              end: end,
              allDay: allDay
            }
            $.post "calendar", data, (res) ->
              calendar.fullCalendar('renderEvent', data, true) if res
          calendar.fullCalendar('unselect')
    });
)