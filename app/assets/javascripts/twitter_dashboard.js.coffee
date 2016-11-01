dashboard_functions = ->
  $('.dashboard-action').click (evt) ->
    evt.stopPropagation()
    evt.preventDefault()

    action = $(evt.target).data('action-name')
    if action != '' && action != null
      $('#dashboard-form-1').find('input#action_name').val(action)
      $('#dashboard-form-1').submit()
      
$(document).on('ready page:load', dashboard_functions)
