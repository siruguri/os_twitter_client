window.AjaxShim = new Object(
  last_known_response: new Object(),
  
  curtain_drop: (text) ->
    $('.toast').addClass('open').text text
    setTimeout ->
        $('.toast').text('').removeClass('open')
        true
      , 2000
    
  spinner_div: ->
    return $('<div>').addClass('spinner')
  bind_actions: (obj) ->
    obj.run_action = obj._run_action.bind obj
    
  _run_action: (id, data, tgt) ->
    # Doc: id => integer; data => string; tgt => node.
    # tgt will have a success/failure class attached to it (specifically, either .disabled or .wtf); it's allowed to be
    # null.

    cdf = this.curtain_drop
    lkr = this.last_known_response
    
    xhr = $.ajax(
      type: 'POST'
      url: '/ajax_api'
      data:
        payload: 'actions/trigger/' + id + '/' + data
    )
    
    promise = xhr.done((d, s, x) ->
        if d.data.hasOwnProperty('mesg')
          cdf d.data.mesg
          lkr.data = d.data.data
        else
          cdf d.data
          lkr.data = d.data
        # If the action's results should be communicated to some other DOM node, where the effect should
        # be observed.
        tgt.addClass 'disabled' unless tgt == null
    ).fail((d, s, x) ->
        # failure
        cdf 'wtf'
        tgt.addClass 'wtf' unless tgt == null
    )

    console.log lkr    
    promise
)
window.AjaxShim.bind_actions(window.AjaxShim)

shim_funcs = ->
  $('.action').click (evt) ->
    # Doc: attach the class action to any button that wants to use this shim, add a data-action-id param which shd be an
    # integer; if there is also a data-node-ref attr, it should css-select a node that will have a success/failure class
    # attached to it (specifically, either .disabled or .wtf)
    target = $(this)

    # A user's browser action can remove the .action class subsequent to handler attachment so the handler makes sure
    # its still allowed to act.
    if !(target.hasClass('action'))
      return null
      
    action_id = target.data('action-id')
    
    if typeof action_id != 'undefined'
      target.prepend window.AjaxShim.spinner_div
      if target.data('node-ref')
        return_target = $('#' + target.data('node-ref'))
      else
        return_target = target
    data = JSON.stringify($(evt.target).data('action-data'))
    promise = window.AjaxShim.run_action action_id, data, return_target
    promise.always( ->
      setTimeout( ->
          $(evt.target).find('.spinner').remove()
          true
        500
      )
    )
      
$(document).on('ready page:load', shim_funcs)
