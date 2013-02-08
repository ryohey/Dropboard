
$(function() {
  var contextMenu;
  contextMenu = function(x, y, title, cancelTitle, okTitle, items, complete) {
    var elm;
    elm = $("#contextMenu").html("<header>\n  <h3>" + title + "</h3>\n</header>\n<div class=\"content\"></div>\n<footer>\n  <a class=\"cancel\">" + cancelTitle + "</a>\n  <a class=\"ok\">" + okTitle + "</a>\n</footer>");
    elm.find(".content").append(items);
    elm.find(".ok").click(function() {
      return complete(elm);
    });
    elm.find(".cancel").click(function() {
      return elm.hide();
    });
    elm.css({
      left: x,
      top: y
    }).show();
    elm.find("input:first").focus();
    return elm;
  };
  return $.getJSON("calendar", function(events) {
    var calendar;
    return calendar = $('#calendar').fullCalendar({
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
      },
      titleFormat: {
        month: 'yyyy年 M月',
        week: '[yyyy年 ]M月 d日{ &#8212;[yyyy年 ][ M月] d日}',
        day: 'yyyy年 M月 d日 dddd'
      },
      columnFormat: {
        month: 'ddd',
        week: 'M/d（ddd）',
        day: 'M/d（ddd）'
      },
      timeFormat: {
        '': 'H:mm',
        agenda: 'H:mm{ - H:mm}'
      },
      /*viewDisplay: (view) ->
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
        })
      */
      allDayText: "終日",
      axisFormat: 'H:mm',
      dayNames: ['日曜日', '月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日'],
      dayNamesShort: ['日', '月', '火', '水', '木', '金', '土'],
      buttonText: {
        prev: '&nbsp;&#9668;&nbsp;',
        next: '&nbsp;&#9658;&nbsp;',
        prevYear: '&nbsp;&lt;&lt;&nbsp;',
        nextYear: '&nbsp;&gt;&gt;&nbsp;',
        today: '今日',
        month: '月',
        week: '週',
        day: '日'
      },
      selectable: true,
      editable: true,
      selectHelper: true,
      events: events,
      dayClick: function(date, allDay, jsEvent, view) {
        return false;
      },
      eventClick: function(event, jsEvent, view) {
        var end, items, showRange, start;
        console.log(event.start);
        start = formatDate(event.start, "HH:mm");
        if (event.end) {
          end = formatDate(event.end, "HH:mm");
        } else {
          end = "00:00";
        }
        items = $("<ul class=\"inputs\">\n  <li>タイトル<input type=\"text\" class=\"title\" value=\"" + event.title + "\"></li>\n  <li><input type=\"checkbox\" class=\"allDay\" value=\"allDay\" " + (event.allDay ? "checked" : "") + ">終日</li>\n  <li class=\"range\">開始<input type=\"text\" class=\"start\" value=\"" + start + "\"></li>\n  <li class=\"range\">終了<input type=\"text\" class=\"end\" value=\"" + end + "\"></li>\n  <li><a class=\"delete\">削除</a></li>\n</ul>");
        showRange = function() {
          if (!items.find(".allDay").attr("checked")) {
            return items.find(".range").show();
          } else {
            return items.find(".range").hide();
          }
        };
        items.find(".allDay").change(showRange);
        showRange();
        return contextMenu(jsEvent.pageX, jsEvent.pageY, "イベントの編集", "キャンセル", "決定", items, function(elm) {
          var endArr, hourExp, startArr;
          elm.hide();
          event.title = elm.find(".title").val();
          hourExp = /([0-9]+)[\:：\s\,]([0-9]+)/;
          if (!items.find(".allDay").attr("checked")) {
            event.allDay = false;
            startArr = elm.find(".start").val().match(hourExp);
            if (startArr.length === 3) {
              event.start.setHours(startArr[1]);
              event.start.setMinutes(startArr[2]);
            }
            endArr = elm.find(".end").val().match(hourExp);
            if (endArr.length === 3) {
              if (!event.end) event.end = new Date(event.start);
              event.end.setHours(endArr[1]);
              event.end.setMinutes(endArr[2]);
            }
          } else {
            event.allDay = true;
          }
          return calendar.fullCalendar("updateEvent", event);
        });
      },
      reportSelection: function() {
        return false;
      },
      daySelectionMousedown: function() {
        return false;
      },
      eventDrop: function(event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view) {
        return false;
      },
      eventResize: function(event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view) {
        return false;
      },
      unselect: function() {
        return false;
      },
      select: function(start, end, allDay, jsEvent, view) {
        var items;
        console.log(arguments);
        items = $("<ul class=\"inputs\">\n  <li>タイトル<input type=\"text\" class=\"title\" value=\"\"></li>\n</ul>");
        return contextMenu(jsEvent.pageX, jsEvent.pageY, "イベントの追加", "キャンセル", "決定", items, function(elm) {
          var data, title;
          elm.hide();
          console.log(elm.find(".title"));
          title = elm.find(".title").val();
          if (title) {
            data = {
              title: title,
              start: start,
              end: end,
              allDay: allDay
            };
            $.post("calendar", data, function(res) {
              if (res) return calendar.fullCalendar('renderEvent', data, true);
            });
          }
          return calendar.fullCalendar('unselect');
        });
      }
    });
  });
});
