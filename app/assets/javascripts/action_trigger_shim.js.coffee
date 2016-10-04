curtain_drop = (text) ->
  $('.toast').addClass('open').text text
  setTimeout ->
      $('.toast').text('').removeClass('open')
      true
      
    , 2000
    
spinner_div = ->
  return $('<div>').addClass('spinner')
  
shim_funcs = ->
  $('.action').click (evt) ->
    # A user's browser action might have removed this class subsequent to handler
    # attachment.
    #
    target = $(evt.target)
    if !(target.hasClass('action'))
      return null
      
    action_id = target.data('action-id')
    if typeof action_id != 'undefined'
      target.prepend spinner_div
      xhr = $.ajax(
        type: 'POST'
        url: '/ajax_api'
        data:
          payload: 'actions/trigger/' + action_id + '/' + $(evt.target).data('action-data')
      )
      
      xhr.done((d, s, x) ->
          curtain_drop d.data
          target.addClass 'disabled'
      ).fail((d, s, x) ->
          # failure
          curtain_drop 'wtf'
          target.addClass 'wtf'
      ).always( ->
        setTimeout( ->
            $(evt.target).find('.spinner').remove()
            true
          500
        )
      )
      
$(document).on('ready page:load', shim_funcs)
