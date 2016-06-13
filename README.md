# elm-calculator

A basic calculator written with [elm-lang](http://elm-lang.org/ "elm-lang").  

[ Demo ](http://chrisbuttery.github.io/elm-calculator/)

![alt tag](https://github.com/chrisbuttery/elm-calculator/blob/master/Elm-Calculator.png)

This app was thrown together pretty quickly for a weekend project and quickly became a race between basic functionality and my short attention span - so maybe it shouldn't be relied upon :p.

## Installation

Install [ elm ](http://elm-lang.org/install)

```
% git clone git@github.com:chrisbuttery/elm-calculator.git
% cd elm-calculator

# install deps
% elm package install

# build
% elm make Main.elm --output elm.js
# or
% npm run build

% open index.html
```


### Why?

This little project grew out of something I wasn't quite sure how to do in Elm, and that was get the value of an element or one of it's attributes. It turns out it's quite easy.

I had wondered how to get a specific data-attribute from a button. say something like:

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

A trivial example of wiring it up, would look something like this.

```
-- abstract "value" from "dataset"
decodeDataAttr : Json.Decode.Decoder String
decodeDataAttr =
  at ["target", "dataset", "value"] string


-- click event
getAttribute : Signal.Address a -> (String -> a) -> Html.Attribute
getAttribute address f =
  on "click" (Json.map SomeAction decodeDataAttr)

-- view
view =
  button [
    attribute "data-value" "1"
    , getAttribute SomeAction
  ] [ text "1" ]

```

So once I had a few buttons rendered to the screen, I was halfway to having a calculator. :)
