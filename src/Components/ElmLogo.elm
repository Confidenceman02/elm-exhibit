module Components.ElmLogo exposing (Color(..), color, custom, large, medium, view)

import Html.Styled as Styled
import Svg.Styled exposing (polygon, svg)
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
        [ polygon [ fill "currentColor", points "0, 20 280, 300 0,580" ] []
        , polygon [ fill "currentColor", points "20,600 300,320 580,600" ] []
        , polygon [ fill "currentColor", points "320,0 600,0 600,280" ] []
        , polygon [ fill "currentColor", points "20,0 280,0 402,122 142,122" ] []
        , polygon [ fill "currentColor", points "170,150 430,150 300,280" ] []
        , polygon [ fill "currentColor", points "320,300 450,170 580,300 450,430" ] []
        , polygon [ fill "currentColor", points "470,450 600,320 600,580" ] []
        ]



-- HELPERS


sizeToFloat : Size -> Float
sizeToFloat size =
    case size of
        Medium ->
            32

        Large ->
            132

        Custom s ->
            s
