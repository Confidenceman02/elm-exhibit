module Components.DummyInput exposing (Config, default, onFocus, view)

import Html.Styled as Styled exposing (input)
import Html.Styled.Attributes exposing (id, readonly, style, tabindex, value)
import Html.Styled.Events as Events


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { variant : Variant
    , onFocus : Maybe msg
    , onBlur : Maybe msg
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
    }



-- MODIFIERS


onFocus : msg -> Config msg -> Config msg
onFocus msg (Config config) =
    Config { config | onFocus = Just msg }


view : Config msg -> String -> Styled.Html msg
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
         , id ("dummy-input-" ++ uniqueId)
         ]
            ++ attribs
        )
        []
