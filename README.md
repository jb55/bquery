# bQuery

Declarative Backbone.js with plugins/middleware

WIP

## Examples

```js
var mouseOvers = function(overElem, toggleElem) {
  return function(v) {
    elem = function() { 
      return _.isString(toggleElem)? v.view().$(toggleElem) : toggleElem;
    }
    v.event("mouseover " + overElem, function() { elem().show() });
    v.event("mouseout " + overElem, function() { elem().hide() });
  }
}

// TestView :: Backbone.View
var TestView = bQuery.view()
                     .use(mouseOvers(".title", "#titleEdit"))
                     .event("click", function(){
                       console.log("clicked the test view!");
                     });
                     .make()
```
