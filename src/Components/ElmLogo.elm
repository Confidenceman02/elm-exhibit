module Components.ElmLogo exposing (Animation(..), Color(..), Size(..), animated, color, size, static, view)

import Array
import Css
import Css.Animations
import Html.Styled as Styled
import Styles.Color exposing (exColorOfficialDarkBlue, exColorOfficialGreen, exColorOfficialLightBlue, exColorOfficialYellow)
import Svg.Styled exposing (Svg, polygon, svg)
import Svg.Styled.Attributes exposing (fill, height, points, viewBox)


type Config
    = Config Configuration


type alias Configuration =
    { variant : Variant
    , size : Size
    , color : Color
    }


type Variant
    = Static
    | Animated Animation


type Size
    = Medium
    | Large
    | Custom Float


type Color
    = Current
    | Official


type Animation
    = BasicBlink


defaults : Configuration
defaults =
    { variant = Static
    , size = Medium
    , color = Current
    }


size : Size -> Config -> Config
size s (Config config) =
    Config { config | size = s }



--VARIANTS


static : Config
static =
    Config { defaults | variant = Static }


animated : Animation -> Config
animated animationType =
    Config { defaults | variant = Animated animationType }



-- MODIFIERS


color : Color -> Config -> Config
color c (Config config) =
    Config { config | color = c }


view : Config -> Styled.Html msg
view ((Config config) as con) =
    svg [ height <| String.fromFloat (sizeToFloat config.size), viewBox "0 0 600 600" ] (logoShapes con)


logoShapes : Config -> List (Svg msg)
logoShapes (Config config) =
    [ logoShape01 config.color
    , logoShape02 config.color
    , logoShape03 config.color
    , logoShape04 config.color
    , logoShape05 config.color
    , logoShape06 config.color
    , logoShape07 config.color
    ]


logoShape01 : Color -> Svg msg
logoShape01 clr =
    let
        resolveColor =
            case clr of
                Current ->
                    "currentColor"

                Official ->
                    exColorOfficialDarkBlue.value
    in
    polygon [ fill resolveColor, points "0, 20 280, 300 0,580" ] []


logoShape02 : Color -> Svg msg
logoShape02 clr =
    let
        resolveColor =
            case clr of
                Current ->
                    "currentColor"

                Official ->
                    exColorOfficialLightBlue.value
    in
    polygon [ fill resolveColor, points "20,600 300,320 580,600" ] []


logoShape03 : Color -> Svg msg
logoShape03 clr =
    let
        resolveColor =
            case clr of
                Current ->
                    "currentColor"

                Official ->
                    exColorOfficialLightBlue.value
    in
    polygon [ fill resolveColor, points "320,0 600,0 600,280" ] []


logoShape04 : Color -> Svg msg
logoShape04 clr =
    let
        resolveColor =
            case clr of
                Current ->
                    "currentColor"

                Official ->
                    exColorOfficialGreen.value
    in
    polygon [ fill resolveColor, points "20,0 280,0 402,122 142,122" ] []


logoShape05 : Color -> Svg msg
logoShape05 clr =
    let
        resolveColor =
            case clr of
                Current ->
                    "currentColor"

                Official ->
                    exColorOfficialYellow.value
    in
    polygon [ fill resolveColor, points "170,150 430,150 300,280" ] []


logoShape06 : Color -> Svg msg
logoShape06 clr =
    let
        resolveColor =
            case clr of
                Current ->
                    "currentColor"

                Official ->
                    exColorOfficialGreen.value
    in
    polygon [ fill resolveColor, points "320,300 450,170 580,300 450,430" ] []


logoShape07 : Color -> Svg msg
logoShape07 clr =
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
sizeToFloat s =
    case s of
        Medium ->
            32

        Large ->
            169

        Custom cs ->
            cs
