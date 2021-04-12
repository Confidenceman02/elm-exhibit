module LoadingPlaceholder.LoadingPlaceholder exposing (animated, colorVariant, default, size, view, width)

import Css
import Css.Animations as CssAnimation
import Html.Styled as Styled exposing (div)
import Html.Styled.Attributes as StyledAttribs


type Config
    = Config Configuration


type Size
    = Normal


type ColorVariant
    = Default


type alias Configuration =
    { animated : Bool
    , colorVariant : ColorVariant
    , size : Size
    , width : Float
    , marginBottom : Bool
    }


default : Config
default =
    Config defaults


defaults : Configuration
defaults =
    { animated = True
    , colorVariant = Default
    , size = Normal
    , width = 100
    , marginBottom = True
    }



-- MODIFIERS


animated : Bool -> Config -> Config
animated value (Config config) =
    Config { config | animated = value }


colorVariant : ColorVariant -> Config -> Config
colorVariant value (Config config) =
    Config { config | colorVariant = value }


size : Size -> Config -> Config
size value (Config config) =
    Config { config | size = value }


width : Float -> Config -> Config
width value (Config config) =
    Config { config | width = value }



-- VIEWS


view : Config -> Styled.Html msg
view (Config config) =
    div
        [ StyledAttribs.css
            (baseStyles
                ++ withSizeStyles config
                ++ withWidthStyles config
                ++ withMarginBottomStyles config
                ++ withAnimationStyles config
            )
        ]
        []



-- STYLES


baseStyles : List Css.Style
baseStyles =
    [ Css.borderRadius (Css.px 21), Css.backgroundColor (Css.hex "#d6d6d6") ]


withSizeStyles : Configuration -> List Css.Style
withSizeStyles config =
    case config.size of
        Normal ->
            [ Css.height (Css.px 15) ]


withWidthStyles : Configuration -> List Css.Style
withWidthStyles config =
    [ Css.width (Css.pct config.width) ]


withMarginBottomStyles : Configuration -> List Css.Style
withMarginBottomStyles config =
    if config.marginBottom then
        [ Css.marginBottom (Css.px 24) ]

    else
        []


withAnimationStyles : Configuration -> List Css.Style
withAnimationStyles config =
    if config.animated then
        [ Css.animationName <| CssAnimation.keyframes [ ( 0, [ CssAnimation.opacity (Css.num 0.6) ] ), ( 50, [ CssAnimation.opacity (Css.num 1) ] ), ( 100, [ CssAnimation.opacity (Css.num 0.6) ] ) ]
        , Css.animationDuration (Css.sec 1)
        , Css.property "animation-iteration-count" "infinite"
        ]

    else
        []
