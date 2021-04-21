module Components.ExhibitPane exposing (ShadowPosition(..), default, defaultContentWidth, heightRatio, shadowPosition, view, widthRatio)

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



-- pane aspect ratio = 4:5


heightRatio : Float
heightRatio =
    5


widthRatio : Float
widthRatio =
    4


defaultContentWidth : Float
defaultContentWidth =
    defaultContentHeight / heightRatio * widthRatio


defaultContentHeight : Float
defaultContentHeight =
    590


view : Config -> List (Styled.Html msg) -> Styled.Html msg
view (Config config) content =
    div [ StyledAttribs.css [ Css.position Css.absolute ] ]
        [ shadow config.shadowPosition config.variant
        , div
            [ StyledAttribs.css
                ([ Css.display Css.block
                 , Css.position Css.relative
                 , Css.overflow Css.hidden
                 , Css.backgroundColor exColorWhite
                 , Css.borderRadius (Css.px 12)
                 ]
                    ++ setDimensionStyles config.variant
                )
            ]
            content
        ]


shadow : ShadowPosition -> Variant -> Styled.Html msg
shadow shadowPos v =
    svg
        [ width "510"
        , height "691"
        , viewBox "0 0 510 691"
        , centerShadowStyles shadowPos
        ]
        [ filter [ id "shadowBlur" ] [ feGaussianBlur [ in_ "sourceGraphics", stdDeviation "7" ] [] ]
        , rect
            ([ x "14.855576"
             , y "16.587036"
             , rx "12"
             , fill exColorColt200.value
             , SvgStyledAttribs.filter "url(#shadowBlur)"
             ]
                ++ setShadowDimensionStyles v
            )
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


setDimensionStyles : Variant -> List Css.Style
setDimensionStyles v =
    case v of
        Default ->
            [ Css.width (Css.px defaultContentWidth), Css.height (Css.px defaultContentHeight) ]


setShadowDimensionStyles : Variant -> List (Svg.Styled.Attribute msg)
setShadowDimensionStyles v =
    case v of
        Default ->
            [ height (String.fromFloat defaultContentHeight), width (String.fromFloat defaultContentWidth) ]
