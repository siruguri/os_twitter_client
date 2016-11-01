analysis_fns = ->
  $('.biotag-search input').keyup (evt) ->
    kc = $(evt.keyCode)[0]
    # Ignore modifier keys
    return if (kc >= 16 && kc <= 18) || kc == 91 || kc == 93
    d = $(evt.target).val()
    if d.length > 3
      window.AjaxShim.run_action(4, d, $('.biotag-search'))
      
$(document).on('ready page:load', analysis_fns)
