functions = ->
  $('.databox#databox-1').show()
  
  $('.selection-box').click (evt) ->
    unless $(evt.target).hasClass('sort-target')
      target_num = $(this).data('target')
      target_id = '#databox-' + target_num
      $('.databox').hide()
      $(target_id).show()

      $('.selection-box').removeClass 'sort-target'
      $(evt.target).addClass 'sort-target'
    
$(document).on('page:load ready', functions)
