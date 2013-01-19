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

bQuery.view.mixin("bound", bound)

UserView =
  bQuery.view()
        .bound("name", (user, newName) ->
          @$(".userName").text(newName)
        )
        .bound("email", (user, newEmail) ->
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
    bqView.bound attr, (model, newValue) ->
      @$(tag).text(newValue)

bQuery.view.mixin "boundText", boundText
```

Notice we're reusing bound from before, but with the specific action of updating
a dom element's text instead.

```js
var UserView =
  bQuery.view()
        .boundText("name", ".userName")
        .boundText("email", ".userEmail")
        .make()
```

Ah, much cleaner.

## Wrapping it as a plugin

To turn your mixins into digestable functions for the masses, you can mix them
directly into the vQuery.view() prototype all at once like so:

```coffee
bQuery.view.mixin({
    bound: bound
  , boundText: boundText
  , doNothing: -> ->
})

```

## How it works

bQuery.view() creates an object called a bQueryView that has the ability to
create Backbone.View objects. By mixing in different functionality you change
the resulting `Backbone.View`. New functionality can be mixed in using the `use`
function until `make` is called, which returns the `Backbone.View`.

All bQueryView does is provide a nice declarative way of mixing in functionality
and setting properties (via `set`). It's simple yet it changes the way you build
your Backbone apps.

## No more `this` gotchas

Since bquery wires all of the callbacks, you no longer have to worry about
the "forgot to bind `this`" problem. You still have to remember to
bind `this` when writing mixins though.

## Reference

`bQuery.view()`: returns a bQueryView

`bQuery.view.mixin(name, mixin)`: Add a mixin to the prototype of `bQueryView`.
This allows you to call the mixin directly by name instead of doing `.use(mixin)`
all the time.

This makes it easy for libraries to plug themselves into bQuery

e.g.

```coffeescript
  # example mixin that alerts when you click .alert
  annoyingAlert = (opts) ->
    return (v) ->
      v.on "click .alert", ->
        alert("hello, " + opts.name)
      # you can even reference other mixins the same way within a mixin!
      v.doNothing()

  bQuery.view.mixin("annoying", annoyingAlert);
  bQuery.view.mixin("doNothing", -> ->)

  bQuery.view()
        .annoying({ name: "bill" })
        .doNothing()
```

`bQuery.view.mixin(mixins)`: Mixin multiple mixins using the dictionary keys as
the name and values as the mixins

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
