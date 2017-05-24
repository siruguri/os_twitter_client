analysis_fns = ->
  $('.biotag-search input').keyup (evt) ->
    return if window.KeyboardTrigger.process_event(evt) == null
    if (d = window.KeyboardTrigger.last_known_response).length > 3
      window.AjaxShim.run_action(4, d, $('.biotag-search'))
      
$(document).on('ready page:load', analysis_fns)
