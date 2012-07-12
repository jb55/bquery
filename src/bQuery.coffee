

class bqView
  constructor: (opts={}) ->
    @_plugins = []
    @_events = []
    @_properties = []
    @_init = []
    @_view = opts.view

  validate: ->

  @validateEvents: (evts) ->

  init: (f) ->
    @_init.push f
    @

  on: (e, f) ->
    @_events.push { name: e, fn: f }
    @

  tagName: (n) -> @set "tagName", n
  el:      (n) -> @set "el", n

  set: (p, v) ->
    @_properties.push { name: p, value: v }
    @

  use: (p) ->
    @_plugins.push p
    @

  view: -> @_view

  run: (v) ->
    v = v or @view()
    p(@, v) for p in @_plugins

    # set up our events
    v::events = =>
      evts = {}
      for e in @_events
        evts[e.name] = e.fn
      return evts

    for p in @_properties
      v::[name] = p.value

    t = @
    v::initialize = ->
      i.call @ for i in t._init
      return
    @

  make: ->
    bQueryView = ->
    v = Backbone.View.extend(bQueryView)
    @_view = v
    @run(v)

    v


class bQuery
  constructor: ->

  @view: -> new bqView
