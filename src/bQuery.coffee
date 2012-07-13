

class bqView
  constructor: (opts={}) ->
    bQueryView = ->

    @_events = []
    @_properties = []
    @_init = []
    @_view = opts.view or Backbone.View.extend(bQueryView)

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

  use: (p) -> p(@, @view)

  view: -> @_view

  make: (v) ->
    v = v or @view()

    # set up our events
    v::events = =>
      evts = {}
      for e in @_events
        evts[e.name] = e.fn
      return evts

    for { name, value } in @_properties
      v::[name] = value

    t = @
    v::initialize = (opts={}) ->
      i.call @, opts for i in t._init
      return

    v

  get: -> make()


class bQuery
  constructor: ->

  @view: -> new bqView
