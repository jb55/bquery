# bQuery

A library for building modular and composable Backbone.js applications

## Overview

bQuery is all about building `Backbone.View`s from small components, compared to
an opinionated framework approach. To see how this works, let's look at a simple
example.

Let's say we wanted to to be notified when a model attribute is updated inside a
view. Let's use a mixin to represent this, here's what it looks like:

```coffee
bound = (attr, update) ->
  return (bqView) ->
    bqView.init -> @model.on "change:#{ attr }", update, @
```

This simply adds a `this.model.on` call to the constructor of a Backbone.View.
When the attribute changes the update function will be called.

I will be using coffeescript in my examples because the function syntax is a bit
nicer for representing bQuery mixins. But javascript would work just as well,
although it's a bit uglier:

```js
var bound = function(attr, update){
  return function(bqView){
    bqView.init(function(){
      this.model.on("change:" + attr, update, this);
    });
  }
}
```

and there we have it, our first mixin! We can now use our new mixin in any of
our bQuery.view()'s like so:

```coffee
UserView =
  bQuery.view()
        .use(bound "name", (user, newName) -> 
          @$(".userName").text(newName)
        )
        .use(bound "email", (user, newEmail) -> 
          @$(".userEmail").text(newEmail)
        )
        .make()
```

Nice! `.userName` and `.userEmail` will now update whenever `name` and `email`
are updated.

Updating a field with text is a pretty common task so lets abstract it further:

```coffee
boundText = (attr, tag) ->
  return (bqView) ->
    bound(attr, (model, newValue) -> 
      @$(tag).text(newValue)
    )(bqView)
```

Notice we're reusing bound from before, but with the specific action of updating
a dom element's text instead.

```js
var UserView =
  bQuery.view()
        .use(boundText("name", ".userName"))
        .use(boundText("email", ".userEmail"))
        .make()
```

Ah, much cleaner.

## How it works

bQuery.view() creates an object called a bQueryView that has the ability to
create Backbone.View objects. By mixing in different functionality you change
the resulting `Backbone.View`. New functionality can be mixed in using the `use`
function until `make` is called, which returns the `Backbone.View`.

All bQueryView does is provide a nice declarative way of mixing in functionality
and setting properties (via `set`). It's simple yet it changes the way you build
your Backbone apps.

## Reference

`bQuery.view()`: returns a bQueryView

### bQueryView

`.use(mixin)` 

Mixin a mixin. A Mixin is a function that takes a (bQueryView, Backbone.View).
Calling use calls the mixin with the current bQueryView.

`.set(prop, val)` 

Adds a property to the `Backbone.View`'s prototype object. `prop` is string and
`val` can be anything.

`.on(event, cb)`

Adds an event handler to the `Backbone.View`. This is equivalent to setting a
property in the events property on the `Backbone.View` object.

`.init(fn)`

Adds functionality to inside of the `Backbone.View`s constructor. Each
registered function is executed in order within the `Backbone.View` constructor.

`.view()`

Access the `Backbone.View` object directly. Usually called before `.make()` to
make changes to the `Backbone.View` object before it is constructed, but this is
rarely needed in practice.

`.make()`

Returns the `Backbone.View` constructor with all the mixed in functionality, set
properties and events.

## Examples

### Toggle visibility mouseovers
```js
var mouseOvers = function(overElem, toggleElem) {
  return function(v) {
    elem = function(t) { 
      return _.isString(toggleElem)? t.$(toggleElem) : toggleElem;
    }
    v.on("mouseover " + overElem, function() { elem(this).show() });
    v.on("mouseout " + overElem, function() { elem(this).hide() });
  }
}
```

### Real life example from production code

```coffee
#=----------------------------------------------------------------------------=#
# TrackView :: View Track
#=----------------------------------------------------------------------------=#
mkTrackView = (trackOpts={}) ->
  @readOnly = trackOpts.readOnly or no
  @public = trackOpts.public or no

  v = bQuery.view()
    .set("tagName", "div")
    .set("className", "track-row")
    .init((opts={}) ->
      @artists = new ArtistCollection { unassigned: no }
      @on "pane:open", ->
        threeSixtyPlayer.init()
      @on "editing:start", => @isEditing = yes
      @on "editing:end",   => @isEditing = no
    )
    .use(Mixins.bq.pane
      click: ".track-box"
      tag: ".track"
      ignoreClick: (elem) -> @isEditing or elem.hasClass "ignore"
    )

#=----------------------------------------------------------------------------=#
# ______ Editor Logic ______
#=----------------------------------------------------------------------------=#

  unless @readOnly
    v.use(Mixins.bq.boundText "artistsTitle", ".artists-title")
      .use(Mixins.bq.boundText "title",        ".track-title")
      .use(Mixins.bq.textbox   "artistsTitle", ".edit-artists-title")
      .use(Mixins.bq.textbox   "title",        ".edit-track-title")
      .use(Mixins.bq.bound "featuring", (m) ->
        @$(".featuring").text(m.featuringJoined())
      )
      .use(Mixins.bq.editbox
        click: ".edit-altNames"
        update: (nv) ->
          elem = @$(".edit-altNames")
          altNames = @model.get("altNames") or []
          altNames.push nv
          @model.save { altNames: altNames },
            error: Mixins.logError
            success: (b) => @$(".altNameList").append(@make "li", {
              "class": "edit-altName clickable"
            }, nv)
          elem.text("Add alternative name")
      )
      .use(Mixins.bq.editbox
        click: ".edit-altName"
        update: (nv, ov, elem) ->
          altNames = @model.get("altNames") or []
          altNames = _(altNames).map (altName) ->
            if ov is altName then nv else altName
          @model.save { altNames: altNames },
            error: (e) =>
              Mixins.logError e
              elem.text(ov)
            success: (b) => elem.text(nv)
      )
      .use(Mixins.bq.editableArtists
        click: ".artists"
        update: (artists) ->
          elem = @$(".artists")
          @model.set "artists", artists
          @model.save()
          elem.text(@model.get("artistsTitle"))
      )
      .use(Mixins.bq.editableArtists
        click: ".edit-featuring"
        type: "featuring"
        update: (artists) ->
          elem = @$(".edit-featuring")
          @model.set "featuring", artists
          @model.save()
          elem.text(@model.featuringJoined())
      )
      .use(Mixins.bq.editableDate
        click: ".edit-releaseDate"
        update: (date) ->
          elem = @$(".releaseDate")
          console.log elem
          @model.set "released", new Date(date).getTime()
          @model.save()
          console.log 'new date: ', date
          elem.text(@model.formateDate())
      )
      .on("click .ok-new-track", ->
        $sl  = @$(".artistsSelectList")
        id   = $sl.val()
        name = @$("option[value='#{ id }']", $sl).text()
        title = @$(".track-name").val()

        artists = @model.get("artists") or []

        artists.push
          artistId: id
          name: name
        @model.set "title", title
        @model.set "artists", artists
        @model.save()
      )
      .on("click #uploadOk", ->
        upload = @$("#uploadTrack")
        fileUpload(@model, upload)
      )
      .use(Mixins.bq.mouseOvers("", ".upload"))
      .on("change .fileupload", (e) ->
        upload = $(e.target)

        $box = @$(".track-box")
        $progress = $(@make 'div', { "class": "progress progress-striped" })
        $bar = $(@make 'div', { "class": "bar active" })
        $progress.append($bar)
        $box.append($progress)

        fileUpload("/trackupload/" + @model.id, upload
          , (prog) =>
            total = prog.loaded / prog.totalSize  * 100
            $bar.css("width", "#{ total }%")
          , (track) =>
            @model.set "song", track.song
            $progress.remove()
            @$('.ui360').show()
            @$('.ui360').attr('href', '/play/' + @model._id + '/' + @model.song)
            threeSixtyPlayer.init()

        )
      )

#=----------------------------------------------------------------------------=#
# ^^^^^ End Editor Logic ^^^^^
#=----------------------------------------------------------------------------=#

  v.use(Mixins.bq.init "track",
    template: (cb) ->
      d = {}
      d.model = @model.toJSON()
      song = @model.get("song")
      featuringTxt = @model.featuringJoined()
      release = @model.formateDate()
      d.extra =
        label: "Monstercat"
        song: @model.song()
        artistsTxt: "hey"
        featuringTxt: featuringTxt
        readOnly: trackOpts.readOnly
        releaseDate: release
      @template d, cb
  )
  .make()

Views.TrackView = TrackView
```
