module Components.ElmLogo exposing (Color(..), color, custom, large, medium, view)

import Html.Styled as Styled
import Styles.Color exposing (exColorOfficialDarkBlue, exColorOfficialGreen, exColorOfficialLightBlue, exColorOfficialYellow)
import Svg.Styled exposing (Svg, polygon, svg)
import Svg.Styled.Attributes exposing (fill, height, points, viewBox)


type Config
    = Config Configuration


type alias Configuration =
    { size : Size
    , color : Color
    }


type Size
    = Medium
    | Large
    | Custom Float


type Color
    = Current
    | Official


defaults : Configuration
defaults =
    { size = Medium
    , color = Current
    }


medium : Config
medium =
    Config { defaults | size = Medium }


large : Config
large =
    Config { defaults | size = Large }


custom : Float -> Config
custom customSize =
    Config { defaults | size = Custom customSize }



-- MODIFIERS


color : Color -> Config -> Config
color c (Config config) =
    Config { config | color = c }


view : Config -> Styled.Html msg
view (Config config) =
    svg [ height <| String.fromFloat (sizeToFloat config.size), viewBox "0 0 600 600" ]
        [ logoPiece01 config.color
        , logoPiece02 config.color
        , logoPiece03 config.color
        , logoPiece04 config.color
        , logoPiece05 config.color
        , logoPiece06 config.color
        , logoPiece07 config.color
        ]


logoPiece01 : Color -> Svg msg
logoPiece01 clr =
    let
        resolveColor =
            case clr of
                Current ->
                    "currentColor"

                Official ->
                    exColorOfficialDarkBlue.value
    in
    polygon [ fill resolveColor, points "0, 20 280, 300 0,580" ] []


logoPiece02 : Color -> Svg msg
logoPiece02 clr =
    let
        resolveColor =
            case clr of
                Current ->
                    "currentColor"

                Official ->
                    exColorOfficialLightBlue.value
    in
    polygon [ fill resolveColor, points "20,600 300,320 580,600" ] []


logoPiece03 : Color -> Svg msg
logoPiece03 clr =
    let
        resolveColor =
            case clr of
                Current ->
                    "currentColor"

                Official ->
                    exColorOfficialLightBlue.value
    in
    polygon [ fill resolveColor, points "320,0 600,0 600,280" ] []


logoPiece04 : Color -> Svg msg
logoPiece04 clr =
    let
        resolveColor =
            case clr of
                Current ->
                    "currentColor"

                Official ->
                    exColorOfficialGreen.value
    in
    polygon [ fill resolveColor, points "20,0 280,0 402,122 142,122" ] []


logoPiece05 : Color -> Svg msg
logoPiece05 clr =
    let
        resolveColor =
            case clr of
                Current ->
                    "currentColor"

                Official ->
                    exColorOfficialYellow.value
    in
    polygon [ fill resolveColor, points "170,150 430,150 300,280" ] []


logoPiece06 : Color -> Svg msg
logoPiece06 clr =
    let
        resolveColor =
            case clr of
                Current ->
                    "currentColor"

                Official ->
                    exColorOfficialGreen.value
    in
    polygon [ fill resolveColor, points "320,300 450,170 580,300 450,430" ] []


logoPiece07 : Color -> Svg msg
logoPiece07 clr =
    let
        resolveColor =
            case clr of
                Current ->
                    "currentColor"

                Official ->
                    exColorOfficialYellow.value
    in
    polygon [ fill resolveColor, points "470,450 600,320 600,580" ] []



-- HELPERS


sizeToFloat : Size -> Float
sizeToFloat size =
    case size of
        Medium ->
            32

        Large ->
            169

        Custom s ->
            s
