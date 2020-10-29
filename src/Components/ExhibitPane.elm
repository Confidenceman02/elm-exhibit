module Components.ExhibitPane exposing (ShadowPosition(..), default, shadowPosition, view)

import Css
import Html.Styled as Styled exposing (Attribute, div)
import Html.Styled.Attributes as StyledAttribs
import Styles.Color exposing (exColorColt200, exColorWhite)
import Styles.Transition as Transition
import Svg.Styled exposing (feGaussianBlur, filter, rect, svg)
import Svg.Styled.Attributes as SvgStyledAttribs exposing (fill, height, id, in_, rx, stdDeviation, viewBox, width, x, y)


type Config
    = Config Configuration


type alias Configuration =
    { variant : Variant
    , shadowPosition : ShadowPosition
    }


type ShadowPosition
    = Center
    | Offset


type Variant
    = Default


defaults : Configuration
defaults =
    { variant = Default
    , shadowPosition = Center
    }


default : Config
default =
    Config defaults



-- MODIFIERS


shadowPosition : ShadowPosition -> Config -> Config
shadowPosition pos (Config config) =
    Config { config | shadowPosition = pos }


centerContentWidth : Float
centerContentWidth =
    460


centerContentHeight : Float
centerContentHeight =
    590


view : Config -> List (Styled.Html msg) -> Styled.Html msg
view (Config config) content =
    div []
        [ shadow config.shadowPosition
        , div
            [ StyledAttribs.css
                [ Css.display Css.block
                , Css.position Css.relative
                , Css.width (Css.px centerContentWidth)
                , Css.height (Css.px centerContentHeight)
                , Css.overflow Css.hidden
                , Css.backgroundColor exColorWhite
                , Css.borderRadius (Css.px 12)
                ]
            ]
            content
        ]


shadow : ShadowPosition -> Styled.Html msg
shadow shadowPos =
    svg
        [ width "510"
        , height "691"
        , viewBox "0 0 510 691"
        , centerShadowStyles shadowPos
        ]
        [ filter [ id "shadowBlur" ] [ feGaussianBlur [ in_ "sourceGraphics", stdDeviation "7" ] [] ]
        , rect
            [ x "14.855576"
            , y "16.587036"
            , rx "12"
            , height (String.fromFloat centerContentHeight)
            , width (String.fromFloat centerContentWidth)
            , fill exColorColt200.value
            , SvgStyledAttribs.filter "url(#shadowBlur)"
            ]
            []
        ]


centerShadowStyles : ShadowPosition -> Attribute msg
centerShadowStyles shadowPos =
    let
        resolveLeft =
            case shadowPos of
                Center ->
                    -3

                Offset ->
                    -4
    in
    SvgStyledAttribs.css
        ([ Css.position Css.absolute
         , Css.top (Css.pct -1.5)
         ]
            ++ Transition.left (Css.pct resolveLeft)
        )
