dashboard_functions = ->
  $('#twitter-handle').keyup (evt) ->
    if $(evt.target).val().length > 0
      x = '/twitter/analysis/' + $(evt.target).val()      
      $('.analysis-link a').text x
      $('.analysis-link a').attr 'href', x
      $('.analysis-link').show()
    else
      $('.analysis-link').hide()

  $('.dashboard-action').click (evt) ->
    evt.stopPropagation()
    evt.preventDefault()
    e = $(evt.target)
    action = e.data 'action-name'
    handle = e.data 'handle'
    if action != '' && action != null
      f = e.closest('form')
      handle_field = f.find('#handle')
      if handle_field.length == 1 and handle_field.val().trim() ==''
        handle_field.val handle
        
      f.find('input#action_name').val action
      f.submit()
      
$(document).on('ready page:load', dashboard_functions)
