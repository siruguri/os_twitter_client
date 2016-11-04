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

    action = $(evt.target).data('action-name')
    if action != '' && action != null
      $('#dashboard-form-1').find('input#action_name').val(action)
      $('#dashboard-form-1').submit()
      
$(document).on('ready page:load', dashboard_functions)
