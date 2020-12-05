module EventsExtra exposing (isDownArrow, isEnter, isSpace, onEnter, onSpace)

import Html.Styled as Styled
import Html.Styled.Events exposing (keyCode, preventDefaultOn)
import Json.Decode as Decode


type Key
    = Escape
    | UpArrow
    | DownArrow
    | Enter
    | Backspace
    | Space
    | Shift
    | Tab
    | Other


backspace : Int
backspace =
    8


tab : Int
tab =
    9


enter : Int
enter =
    13


escape : Int
escape =
    27


upArrow : Int
upArrow =
    38


downArrow : Int
downArrow =
    40


space : Int
space =
    32


shift : Int
shift =
    16


keyCodeToKey : Int -> Key
keyCodeToKey keyCode =
    if keyCode == escape then
        Escape

    else if keyCode == backspace then
        Backspace

    else if keyCode == upArrow then
        UpArrow

    else if keyCode == downArrow then
        DownArrow

    else if keyCode == enter then
        Enter

    else if keyCode == space then
        Space

    else if keyCode == shift then
        Shift

    else if keyCode == tab then
        Tab

    else
        Other


decoder : Int -> Key
decoder =
    keyCodeToKey


onEnter : msg -> Styled.Attribute msg
onEnter msg =
    onKeyDown <| isEnter msg


onSpace : msg -> Styled.Attribute msg
onSpace msg =
    onKeyDown <| isSpace msg


isCode : Key -> msg -> Int -> Decode.Decoder msg
isCode key msg code =
    if decoder code == key then
        Decode.succeed msg

    else
        Decode.fail "not the right key"


isSpace : msg -> Decode.Decoder msg
isSpace msg =
    keyCode |> Decode.andThen (isCode Space msg)


isEnter : msg -> Decode.Decoder msg
isEnter msg =
    keyCode |> Decode.andThen (isCode Enter msg)


isDownArrow : msg -> Decode.Decoder msg
isDownArrow msg =
    keyCode |> Decode.andThen (isCode DownArrow msg)


onKeyDown : Decode.Decoder msg -> Styled.Attribute msg
onKeyDown dec =
    preventDefaultOn "keydown" <|
        Decode.map (\msg -> ( msg, True )) dec
