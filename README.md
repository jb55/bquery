# bQuery

Declarative Backbone.js with plugins/middleware

WIP

## Examples

```js
var mouseOvers = function(overElem, toggleElem) {
  return function(v) {
    elem = function(e) { 
      return _.isString(toggleElem)? e.$(toggleElem) : toggleElem;
    }
    v.on("mouseover " + overElem, function() { elem(e).show() });
    v.on("mouseout " + overElem, function() { elem(e).hide() });
  }
}

// TestView :: Backbone.View
var TestView = bQuery.view()
                     .use(mouseOvers(".title", "#titleEdit"))
                     .on("click", function(){
                       console.log("clicked the test view!");
                     });
                     .make()
```
