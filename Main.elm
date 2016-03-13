module Main (..) where

import Html exposing (div, button, text, input, span)
import Html.Events exposing (onClick, on, targetValue)
import Html.Attributes exposing (id, class, attribute, type', value, classList)
import StartApp.Simple as StartApp
import Json.Decode exposing (..)
import String
import List


-- Events


onInput : Signal.Address a -> (String -> a) -> Html.Attribute
onInput address f =
  on "input" targetValue (\v -> Signal.message address (f v))


decodeButtonText : Json.Decode.Decoder String
decodeButtonText =
  at [ "target", "innerText" ] string


getTriggeredValue : Signal.Address a -> (String -> a) -> Html.Attribute
getTriggeredValue address f =
  on "click" decodeButtonText (\v -> Signal.message address (f v))



-- Helpers


classNames : List String -> Html.Attribute
classNames strings =
  classList (List.map (\str -> ( str, True )) strings)


parseFloat : String -> Float
parseFloat string =
  case String.toFloat string of
    Ok value ->
      value

    Err error ->
      0



-- Model


type alias Model =
  { total : Float
  , lastCalculation : Float
  , input : String
  , operation : String
  , allClear : Bool
  }


initialModel : Model
initialModel =
  { total = 0
  , lastCalculation = 0
  , input = ""
  , operation = ""
  , allClear = True
  }



-- Operations


sum : Float -> Float -> Float
sum x y =
  x + y


multiply : Float -> Float -> Float
multiply x y =
  x * y


division : Float -> Float -> Float
division x y =
  x / y


subtraction : Float -> Float -> Float
subtraction x y =
  x - y



-- Action


type Action
  = AllClear
  | Clear
  | UpdateField String
  | Sum
  | Subtract
  | Divide
  | Multiply
  | Equals
  | Decimal
  | Negate
  | Percent



-- Update


update : Action -> Model -> Model
update action model =
  case action of
    AllClear ->
      initialModel

    Clear ->
      let
        total =
          if model.input == "" then
            0
          else
            model.total
      in
        { model
          | operation = ""
          , input = ""
          , total = total
          , allClear = True
        }

    UpdateField str ->
      { model
        | input = model.input ++ str
        , allClear = False
      }

    Percent ->
      let
        input =
          if model.input /= "" then
            toString ((parseFloat model.input) / 100)
          else
            ""

        total =
          if model.input == "" then
            model.total / 100
          else
            model.total
      in
        { model | input = input, total = total }

    Negate ->
      let
        total =
          if model.input == "" then
            negate model.total
          else
            model.total

        input =
          if model.input /= "" then
            toString (negate (parseFloat model.input))
          else
            model.input
      in
        { model | input = input, total = total }

    Decimal ->
      let
        total =
          if model.input == "" && model.total == 0 then
            0.0
          else
            model.total

        input =
          if model.input == "" && model.total == 0 then
            ".0"
          else if model.input /= "" then
            model.input ++ "."
          else
            model.input
      in
        { model | input = input, total = total }

    Sum ->
      { model
        | operation = "Sum"
        , total = model.total + parseFloat model.input
        , input = ""
      }

    Subtract ->
      let
        total =
          if model.input /= "" && model.total /= 0 then
            model.total - (parseFloat model.input)
          else if model.input == "" && model.total /= 0 then
            model.total
          else
            parseFloat model.input
      in
        { model
          | operation = "Subtract"
          , total = total
          , input = ""
        }

    Multiply ->
      let
        total =
          if model.input /= "" then
            parseFloat model.input
          else if model.total /= 0 && model.input /= "" then
            model.total * parseFloat model.input
          else
            model.lastCalculation
      in
        { model
          | operation = "Multiply"
          , total = total
          , input = ""
        }

    Divide ->
      let
        total =
          if model.input /= "" then
            parseFloat model.input
          else if model.total /= 0 && model.input /= "" then
            model.total / parseFloat model.input
          else
            model.lastCalculation
      in
        { model
          | operation = "Divide"
          , total = total
          , input = ""
        }

    Equals ->
      case model.operation of
        "Sum" ->
          { model
            | operation = ""
            , total = (model.total + parseFloat model.input)
            , lastCalculation = (model.total + parseFloat model.input)
            , input = ""
          }

        "Subtract" ->
          let
            total =
              (model.total - parseFloat model.input)
          in
            { model
              | operation = ""
              , total = total
              , lastCalculation = (model.total - parseFloat model.input)
              , input = ""
            }

        "Multiply" ->
          { model
            | operation = ""
            , total = (model.total * parseFloat model.input)
            , lastCalculation = (model.total * parseFloat model.input)
            , input = ""
          }

        "Divide" ->
          { model
            | operation = ""
            , total = (model.total / parseFloat model.input)
            , lastCalculation = (model.total / parseFloat model.input)
            , input = ""
          }

        _ ->
          model



-- View


renderNumberButton : String -> Signal.Address Action -> Html.Html
renderNumberButton val address =
  button
    [ classNames [ "btn" ], getTriggeredValue address UpdateField ]
    [ text val ]


renderOutput : Model -> Html.Html
renderOutput model =
  div
    [ classNames [ "output" ] ]
    [ span
        [ if model.input == "" then
            classNames [ "hidden" ]
          else
            classNames [ "visible" ]
        ]
        [ text model.input ]
    , span
        [ if model.input == "" then
            classNames [ "visible" ]
          else
            classNames [ "hidden" ]
        ]
        [ text (toString model.total) ]
    ]


renderOperator : String -> Signal.Address Action -> Action -> Html.Html
renderOperator val address action =
  button
    [ classNames [ "btn", "btn__operator" ]
    , onClick address action
    ]
    [ text val ]


renderAction : String -> Signal.Address Action -> Action -> Html.Html
renderAction val address action =
  button
    [ classNames [ "btn", "btn__action" ]
    , onClick address action
    ]
    [ text val ]


view : Signal.Address Action -> Model -> Html.Html
view address model =
  div
    []
    [ div [ classNames [ "model", "hidden" ] ] [ text (toString model) ]
    , div
        [ classNames [ "calculator" ] ]
        [ renderOutput model
        , div
            []
            [ button
                [ if model.allClear == True then
                    classNames [ "btn btn__action" ]
                  else
                    classNames [ "hidden" ]
                , onClick address AllClear
                ]
                [ text "AC" ]
            , button
                [ if model.allClear == True then
                    classNames [ "hidden" ]
                  else
                    classNames [ "btn btn__action" ]
                , onClick address Clear
                ]
                [ text "C" ]
            , renderAction "+/-" address Negate
            , renderAction "%" address Percent
            , renderOperator "/" address Divide
            ]
        , div
            []
            [ renderNumberButton "7" address
            , renderNumberButton "8" address
            , renderNumberButton "9" address
            , renderOperator "*" address Multiply
            ]
        , div
            []
            [ renderNumberButton "4" address
            , renderNumberButton "5" address
            , renderNumberButton "6" address
            , renderOperator "-" address Subtract
            ]
        , div
            []
            [ renderNumberButton "1" address
            , renderNumberButton "2" address
            , renderNumberButton "3" address
            , renderOperator "+" address Sum
            ]
        , div
            []
            [ button
                [ classNames [ "btn", "btn__zero" ]
                , getTriggeredValue address UpdateField
                ]
                [ text "0" ]
            , button
                [ classNames [ "btn", "btn_zero" ]
                , onClick address Decimal
                ]
                [ text "." ]
            , renderOperator "=" address Equals
            ]
        ]
    ]



-- Main


main : Signal Html.Html
main =
  StartApp.start
    { model = initialModel
    , view = view
    , update = update
    }
