TrackStatus.Views.MessageView = Backbone.View.extend
  className: 'message'
  events:
    'keyup input#message-text': (evt) ->
      @model.set('message', $(evt.target).val())
      
  initialize: ->
    _.bindAll @, 'render'
  render: ->
    @$el.html(_.template($("#message-template").html())(@model.attributes))
    @
  
