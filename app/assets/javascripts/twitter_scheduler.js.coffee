scheduler_functions = ->
  mesg_coll = new TrackStatus.Collections.MessageCollection()
  list_view = new TrackStatus.Views.MessageListView
    collection: mesg_coll
  $('#message-list').append(list_view.$el)
  
  $('#add-message').click (evt) ->
    m = new TrackStatus.Models.Message()
    mesg_coll.add m
    
  $('#schedule-submit').click (evt) ->
    evt.stopPropagation()
    opts =
      message_list: mesg_coll.toJSON()
      uri: $('#uri').val()
      
    $.post('/twitter/schedule',
      data: opts
      success: (d, s, x) ->
        alert('scheduled')
    )
    false
    
$(document).on('ready page:load', scheduler_functions)
