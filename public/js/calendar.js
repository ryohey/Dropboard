
$(function() {
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
      select: function(start, end, allDay) {
        var data, title;
        title = prompt('Event Title:');
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
      },
      events: events
    });
  });
});
