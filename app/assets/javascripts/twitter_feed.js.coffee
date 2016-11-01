shown_time = {}
countdown_timer = null

rotate = (obj, prop, mod) ->
  # return whether there was a carry
  if obj.hasOwnProperty prop
    new_val = obj[prop] - 1
    if new_val == -1
      new_val = mod - 1
      ret = true
    else
      ret = false
  obj[prop] = new_val
  ret
  
rotate_time = (time_obj) ->
  carry = rotate(time_obj, 'secs', 60)
  if carry
    carry = rotate(time_obj, 'mins', 60)
    if carry
      carry = rotate(time_obj, 'hrs', 24)
      if carry
        # Stop the clock!
        clearInterval countdown_timer
  $('.countdown .hrs').text time_obj.hrs
  $('.countdown .mins').text time_obj.mins
  $('.countdown .secs').text time_obj.secs
  
  null

twitter_feed_functions = ->
  # Run the timer to the next refresh
  data_elt = $('.time_data')
  shown_time =
    hrs: data_elt.data('hrs')
    mins: data_elt.data('mins')
    secs: data_elt.data('secs')
  countdown_timer = setInterval rotate_time, 1000, shown_time  

  # Get all the tweets that have been retweeted
  page_tweet_id_list = $('.item').get()
  ids = page_tweet_id_list.map (e, i) ->
    $(e).data('action-data')
  unless ids.length == 0
    d = JSON.stringify(ids)
    promise = window.AjaxShim.run_action 3, d, null
    promise.always ->
      if window.AjaxShim.last_known_response.data != null
        page_tweet_id_list.forEach (e, i) ->
          if window.AjaxShim.last_known_response.data.includes(parseInt($(e).data('action-data')))
            $(e).addClass 'disabled'

  # Show blown up images
  $('.tweet-media img').click (evt) ->
    tgt = $(event.target)
    overlay_div = $('.' + tgt.data('overlay-div-class'))
    $('.overlay-grayout').show()
    overlay_div.find('img').attr('src', tgt.attr('src'))
    overlay_div.show()

  # Go to original
  $('.action-button#goto-orig').click (evt) ->
    tgt = $(this).closest('.item')
    id = tgt.data('action-data')
    handle = tgt.data('handle')
    url = 'https://www.twitter.com/' + handle + '/status/' + id
    window.open(url, '_blank')
    
  # Make retweets open overlay
  $('.action-button#retweet-dialog').click (evt) ->
    tgt = $(this).closest('.item')
    overlay_div = tgt.data('overlay-div-class')
    
    if tgt.hasClass('disabled')
      evt.stopPropagation()
      return false
      
    d = tgt.attr('id')
    $('.overlay-grayout').show()
    $('.' + overlay_div).show()
    
    $('.overlay-grayout #retweet').attr('data-node-ref', d)
    o = new Object
    
    o['tweet_id'] = tgt.data('action-data')
    $('.overlay-grayout #retweet').data('action-data', o)
    
  $('.overlay-grayout #quote-entry').keyup (evt)->
    btn = $('.overlay-grayout #retweet')
    btn.data('action-data')['quote'] = $(evt.target).text().trim()
    
  $('.overlay-grayout #retweet').click (evt) ->
    $('.overlay-grayout').hide()
    true
  $('.overlay-grayout .x-box').click (evt) ->
    $('.overlay-grayout').hide()
    
  # Close overlay with ESC (escape) key
  $('body').keyup (evt) ->
    code = if (evt.keyCode) then evt.keyCode else evt.which
    if code == 27 # ESC
      $('.overlay-grayout').hide()
    
$(document).on('page:load ready', twitter_feed_functions)
