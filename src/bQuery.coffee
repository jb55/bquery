

class bqView
  constructor: (opts={}) ->
    @plugins = []
    @events = []
    @_view = opts.view

  validate: ->

  @validateEvents: (evts) ->

  use: (p) ->
    @plugins.push(p)
    @

  event: (e, f) ->
    @events.push { name: e, fn: f }
    @

  view: -> @_view

  run: ->
    p(@, @view()) for p in @plugins
    @

  make: ->
    v = new Backbone.View
    @_view = v
    @run()

    # set up our events
    v.events = =>
      evts = {}
      for e in @events
        evts[e.name] = e.f
      return evts

    v


class bQuery
  constructor: ->

  @view: -> new bqView
