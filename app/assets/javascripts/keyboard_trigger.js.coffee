window.KeyboardTrigger = new Object
  last_known_response: ''
  trigger_cbk: null
  running_interval: null
  wrap_cbk:  (context) ->
    
    
  _process_event: (evt, evt_trigger) ->
    # evt should have a target that responds to val();
    # if event is not a modifier, and event's val(), stripped, is more than 3 characters long,
    # and enough time has passed since the last time we were here (600 ms)
    # return 0 else return null

    kc = $(evt.keyCode)[0]
    # Ignore modifier keys
    return null if (kc >= 16 && kc <= 18) || kc == 91 || kc == 93
    
    examined_data = $(evt.target).val().trim()
    if @last_known_response != examined_data
      # kill old timer
      if @running_interval != null
        clearInterval @running_interval
        
      # start the timer.
      @trigger_cbk = evt_trigger      
      @running_interval = setInterval(@wrap_cbk, 3000, @)
      @last_known_response = examined_data

window.KeyboardTrigger.process_event = window.KeyboardTrigger._process_event.bind(window.KeyboardTrigger)
