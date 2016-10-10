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
    target = $(this)
    if !(target.hasClass('action'))
      return null
      
    action_id = target.data('action-id')
    if typeof action_id != 'undefined'
      target.prepend spinner_div
      if target.data('node-ref')
        return_target = $('#' + target.data('node-ref'))
      else
        return_target = target            
      
      xhr = $.ajax(
        type: 'POST'
        url: '/ajax_api'
        data:
          payload: 'actions/trigger/' + action_id + '/' + JSON.stringify($(evt.target).data('action-data'))
      )
      xhr.done((d, s, x) ->
          curtain_drop d.data

          # If the action's results should be communicated to some other button which is where the effect should
          # be observed... this is very complicated
          return_target.addClass 'disabled'
      ).fail((d, s, x) ->
          # failure
          curtain_drop 'wtf'
          return_target.addClass 'wtf'
      ).always( ->
        setTimeout( ->
            $(evt.target).find('.spinner').remove()
            true
          500
        )
      )
      
$(document).on('ready page:load', shim_funcs)
