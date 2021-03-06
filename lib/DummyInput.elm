module DummyInput exposing (Config, default, inputIdPrefix, onBlur, onFocus, preventKeydownOn, view)

import Html exposing (Html, input)
import Html.Attributes exposing (id, readonly, style, tabindex, value)
import Html.Events as Events exposing (preventDefaultOn)
import Json.Decode as Decode



-- CONSTANTS


inputIdPrefix : String
inputIdPrefix =
    "dummy-input-"


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { variant : Variant
    , onFocus : Maybe msg
    , onBlur : Maybe msg
    , preventKeydownOnOneOf : List (Decode.Decoder msg)
    }


type Variant
    = Default



-- VARIANT


default : Config msg
default =
    Config defaults


defaults : Configuration msg
defaults =
    { variant = Default
    , onFocus = Nothing
    , onBlur = Nothing
    , preventKeydownOnOneOf = []
    }



-- MODIFIERS


onFocus : msg -> Config msg -> Config msg
onFocus msg (Config config) =
    Config { config | onFocus = Just msg }


onBlur : msg -> Config msg -> Config msg
onBlur msg (Config config) =
    Config { config | onBlur = Just msg }


preventKeydownOn : List (Decode.Decoder msg) -> Config msg -> Config msg
preventKeydownOn decoders (Config config) =
    Config { config | preventKeydownOnOneOf = decoders }


view : Config msg -> String -> Html msg
view (Config config) uniqueId =
    let
        withOnfocus msg =
            Events.onFocus msg

        withOnBlur msg =
            Events.onBlur msg

        attribs =
            List.filterMap identity
                [ Maybe.map withOnfocus config.onFocus
                , Maybe.map withOnBlur config.onBlur
                ]
                ++ [ preventOn ]

        preventOn =
            preventDefaultOn "keydown" <|
                Decode.map
                    (\m -> ( m, True ))
                    (Decode.oneOf config.preventKeydownOnOneOf)
    in
    input
        ([ style "label" "dummyInput"
         , style "background" "0"
         , style "border" "0"
         , style "font-size" "inherit"
         , style "outline" "0"
         , style "padding" "0"
         , style "width" "1px"
         , style "color" "transparent"
         , readonly True
         , value ""
         , tabindex 0
         , id (inputIdPrefix ++ uniqueId)
         , style "position" "absolute"
         ]
            ++ attribs
        )
        []
