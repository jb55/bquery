# bQuery

Declarative Backbone.js with plugins/middleware

WIP

## Examples

## Toggle visibility mouseovers

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

## Editable fields

```coffeescript
#=----------------------------------------------------------------------------=#
# editable bQuery plugin
#   editable elements bound to model fields
#   opts: {
#     updateModel : function(newValue)    OR    field : string
#     click : string, when this element is clicked, editing begins
#     edit : string, the element to be edited
#   }
#=----------------------------------------------------------------------------=#
editable = (opts={}) ->
  return (v) ->
    v.on "click " + opts.click, (e) ->
      $edit = @$(opts.edit)

      idAttr =
        if opts.edit[0] is "#"
          { id: opts.edit[1..] }
        else if opts.edit[0] is "."
          { "class": opts.edit[1..] }
        else
          {}

      txt = $edit.text()
      input = @make("input", _.extend({
        type: "text",
        value: txt
      }, idAttr))

      $edit.html(input)
      $edit = @$(opts.edit)
      $edit.focus()
      @trigger "editing:start", $edit

    finish = (e) ->
      value = $(e.srcElement).val()
      if opts.updateModel
        opts.updateModel.call @, value
      else
        @model.set opts.field
      @trigger "editing:end"

    v.on "blur " + opts.edit, (e) -> finish.call @, e
    v.on "keydown " + opts.edit, (e) ->
      if (e.which or e.keyCode) is 13
        e.preventDefault()
        finish.call @, e
        return false
```

```js
// TestView :: Backbone.View
var TestView = bQuery.view()
                     .use(mouseOvers(".title", "#titleEdit"))
                     .use(editable({
                       click: ".test-edit",
                       edit: ".test-text",
                       field: "test"
                     }))
                     .on("click", function(){
                       console.log("clicked the test view!");
                     });
                     .make()
```
