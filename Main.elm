module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick, on, targetValue)
import Html.Attributes exposing (id, class, attribute, type', value, classList)
import Html.App as Html
import Json.Decode exposing (..)
import String
import List
import Json.Decode as Json


-- Events


-- decodeButtonText : Json.Decode.Decoder String
decodeButtonText =
  at [ "target", "innerText" ] string


-- getTriggeredValue : Signal.Address a -> (String -> a) -> Attribute
getTriggeredValue =
  on "click" (Json.map UpdateField decodeButtonText)


-- Helpers


classNames : List String -> Attribute Msg
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


type Msg
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    AllClear ->
      ( initialModel, Cmd.none )

    Clear ->
      let
        total =
          if model.input == "" then
            0
          else
            model.total
      in
        ( { model
          | operation = ""
          , input = ""
          , total = total
          , allClear = True
        }, Cmd.none )

    UpdateField str ->
      ( { model
        | input = model.input ++ str
        , allClear = False
      }, Cmd.none )

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
        ( { model
          | input = input
          , total = total
        }, Cmd.none )

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
        ( { model
          | input = input
          , total = total
        }, Cmd.none )

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
        ({ model
          | input = input
          , total = total
          }, Cmd.none )

    Sum ->
      ( { model
        | operation = "Sum"
        , total = model.total + parseFloat model.input
        , input = ""
      }, Cmd.none )

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
        ({ model
          | operation = "Subtract"
          , total = total
          , input = ""
        }, Cmd.none )

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
        ( { model
          | operation = "Multiply"
          , total = total
          , input = ""
        }, Cmd.none )

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
        ({ model
          | operation = "Divide"
          , total = total
          , input = ""
        }, Cmd.none )

    Equals ->
      case model.operation of
        "Sum" ->
          ( { model
            | operation = ""
            , total = (model.total + parseFloat model.input)
            , lastCalculation = (model.total + parseFloat model.input)
            , input = ""
          }, Cmd.none )

        "Subtract" ->
          let
            total =
              (model.total - parseFloat model.input)
          in
            ( { model
              | operation = ""
              , total = total
              , lastCalculation = (model.total - parseFloat model.input)
              , input = ""
            }, Cmd.none )

        "Multiply" ->
          ( { model
            | operation = ""
            , total = (model.total * parseFloat model.input)
            , lastCalculation = (model.total * parseFloat model.input)
            , input = ""
          }, Cmd.none )

        "Divide" ->
          ( { model
            | operation = ""
            , total = (model.total / parseFloat model.input)
            , lastCalculation = (model.total / parseFloat model.input)
            , input = ""
          }, Cmd.none )

        _ ->
          ( model, Cmd.none )


-- View


renderNumberButton : String -> Html Msg
renderNumberButton val =
  button
    [ classNames [ "btn" ], getTriggeredValue ]
    [ text val ]


renderOutput : Model -> Html Msg
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


renderOperator : String -> Msg -> Html Msg
renderOperator val action =
  button
    [ classNames [ "btn", "btn__operator" ]
    , onClick action
    ]
    [ text val ]


renderAction : String -> Msg -> Html Msg
renderAction val action =
  button
    [ classNames [ "btn", "btn__action" ]
    , onClick action
    ]
    [ text val ]


view : Model -> Html Msg
view model =
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
                , onClick AllClear
                ]
                [ text "AC" ]
            , button
                [ if model.allClear == True then
                    classNames [ "hidden" ]
                  else
                    classNames [ "btn btn__action" ]
                , onClick Clear
                ]
                [ text "C" ]
            , renderAction "+/-" Negate
            , renderAction "%" Percent
            , renderOperator "/" Divide
            ]
        , div
            []
            [ renderNumberButton "7"
            , renderNumberButton "8"
            , renderNumberButton "9"
            , renderOperator "*" Multiply
            ]
        , div
            []
            [ renderNumberButton "4"
            , renderNumberButton "5"
            , renderNumberButton "6"
            , renderOperator "-" Subtract
            ]
        , div
            []
            [ renderNumberButton "1"
            , renderNumberButton "2"
            , renderNumberButton "3"
            , renderOperator "+" Sum
            ]
        , div
            []
            [ button
                [ classNames [ "btn", "btn__zero" ]
                , getTriggeredValue
                ]
                [ text "0" ]
            , button
                [ classNames [ "btn", "btn_zero" ]
                , onClick Decimal
                ]
                [ text "." ]
            , renderOperator "=" Equals
            ]
        ]
    ]



-- Main


-- main : Signal Html
main =
  Html.program
    { init = ( initialModel, Cmd.none )
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }
