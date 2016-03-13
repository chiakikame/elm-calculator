# elm-calculator

A basic calculator written with [elm-lang](http://elm-lang.org/ "elm-lang").  
Just be warned that it was thrown together pretty quickly and maybe shouldn't be relied upon :p.

![alt tag](https://github.com/chrisbuttery/elm-calculator/blob/master/Elm-Calculator.png)

[ Try it out here ](http://chrisbuttery.github.io/elm-calculator/)

## Installation

Install [ elm ](http://elm-lang.org/install)

```
% git clone git@github.com:chrisbuttery/elm-calculator.git
% cd elm-calculator

% elm make Main.elm --output elm.js

% open index.html
```


### Why?

This little project grew out of something I wasn't quite sure how to do in Elm, and that was get the value of an element or one of it's attributes. It turns out it's quite easy.

Originally I had wondered how to get a data-attribute from a button. say something like:

```
button [ html.attribute "data-value" "1" ] [ text "1"]
```
This would render :

```
  <button data-value="1">1</button>
```

Elm's [Html package](http://package.elm-lang.org/packages/evancz/elm-html/4.0.2) gives us access to a decoder helper called [targetValue](http://package.elm-lang.org/packages/evancz/elm-html/4.0.2/Html-Events#targetValue) which is great for getting the `e.target.value` of an text input - but what about a `button` or a `span` element?

`targetValue`'s [source code](https://github.com/evancz/elm-html/blob/4.0.2/src/Html/Events.elm#L100) looks like this:

```
targetValue : Json.Decoder String
targetValue =
    at ["target", "value"] string
```

So using `Json.Decoder` elm looks for the `target` property in `e.target` object and then returns it's `value` property. Ok easy.

So we can set up our own decoder to return whatever prop we want. So in then case above with `data-value` we could just have something like:

```
decodeDataAttr : Json.Decode.Decoder String
decodeDataAttr =
  at ["target", "dataset", "value"] string
```

This will look in `e.target`'s `dataset` and pluck out `value` or whatever our attribute is called. It's pretty straight forward.

A non working example of wiring it up, would look something like this.

```
decodeDataAttr : Json.Decode.Decoder String
decodeDataAttr =
  at ["target", "dataset", "value"] string


getAttribute : Signal.Address a -> (String -> a) -> Html.Attribute
getAttribute address f =
  on "click" decodeDataAttr (\v -> Signal.message address (f v))

view =
  button [
    attribute "data-value" "1"
    , getAttribute address SomeAction
  ] [ text "1" ]

```

So once I had a few buttons rendered to the screen, I was halfway to having a calculator. :)
