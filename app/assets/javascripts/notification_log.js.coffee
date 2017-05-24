fs = ->
  get_logs = ->
    make_box = (rec) ->
      box = $('<div>').addClass('.list-item').append($('<div>').addClass('desc').text(rec[0]))
      box.append $('<div>').addClass('time').text(rec[1])
      
      box
    update = (d, s, x) ->
      (root = $('.list-box')).html ''
      d.data.forEach (m, i) ->
        root.append make_box(m)
        
    $.ajax('/notification_logs/list.json',
      method: 'get'
      data: {}
      success: update
    )

  setInterval get_logs, 10000
      
$(document).on('ready page:load', fs)    
