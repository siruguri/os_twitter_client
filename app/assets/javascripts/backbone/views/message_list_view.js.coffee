TrackStatus.Views.MessageListView = Backbone.View.extend
  className: 'message-list'
  initialize: ->
    _.bindAll @, 'render'
    @listenTo(@collection, 'update', @render)
    @
    
  render: ->
    @$el.html ''
    
    coll_self = @
    @collection.models.forEach (elt, idx) ->
      v = new TrackStatus.Views.MessageView
        model: elt

      coll_self.$el.append(v.render().$el)
    @
