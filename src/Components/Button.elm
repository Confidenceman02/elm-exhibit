module Components.Button exposing (Icon(..), Orientation(..), icon, onClick, secondary, view)

import Css exposing (Style)
import Html.Styled as Styled exposing (button, span, text)
import Html.Styled.Attributes as StyledAttribs
import Html.Styled.Events as Events
import Styles.Grid as Grid
import Styles.Transition as Transition
import Svg.Styled exposing (polygon, svg)
import Svg.Styled.Attributes as SvgAttribs exposing (fill, height, points, viewBox)


type Variant
    = Secondary
    | IconButton Icon


type Icon
    = Triangle Orientation


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { variant : Variant
    , onClick : Maybe msg
    }


type Orientation
    = Closed
    | Open


defaults : Configuration msg
defaults =
    { variant = Secondary
    , onClick = Nothing
    }


secondary : Config msg
secondary =
    Config { defaults | variant = Secondary }


icon : Icon -> Config msg
icon iconType =
    Config { defaults | variant = IconButton iconType }


view : Config msg -> String -> Styled.Html msg
view (Config config) label =
    let
        onClickMsg msg =
            Events.onClick msg

        eventAttribs =
            List.filterMap identity
                [ Maybe.map onClickMsg config.onClick ]

        calc =
            (Css.calc Grid.halfGrid Css.minus (Css.px 2)).value

        resolveStyles =
            case config.variant of
                Secondary ->
                    secondaryStyles

                IconButton _ ->
                    iconStyles

        resolveButtonBody =
            case config.variant of
                Secondary ->
                    [ span
                        [ StyledAttribs.css
                            [ Css.fontSize (Css.rem 1.125)
                            , Css.property "padding" <| calc
                            , Css.height (Css.pct 100)
                            ]
                        ]
                        [ text label ]
                    ]

                IconButton (Triangle orientation) ->
                    [ triangle orientation ]
    in
    button
        ([ StyledAttribs.css resolveStyles ] ++ eventAttribs)
        resolveButtonBody


triangle : Orientation -> Styled.Html msg
triangle orientation =
    let
        resolveDeg =
            case orientation of
                Open ->
                    180

                _ ->
                    0
    in
    svg
        [ height "32"
        , viewBox "0 0 150 300"
        , SvgAttribs.css <|
            Transition.transform (Css.rotate <| Css.deg resolveDeg)
        ]
        [ polygon [ fill "orange", points "0, 150 150, 0 150,300" ] [] ]



-- STYLES


secondaryStyles : List Style
secondaryStyles =
    [ Css.displayFlex
    , Css.color (Css.hex "#859900")
    , Css.fontWeight (Css.int 700)
    , Css.boxSizing Css.borderBox
    , Css.backgroundColor Css.transparent
    , Css.borderColor (Css.rgba 0 0 0 0)
    , Css.hover [ Css.backgroundColor (Css.hex "#f0f1f4") ] -- $kz-color-wisteria-100
    , Css.border (Css.px 2)
    , Css.padding (Css.px 0)
    ]


iconStyles : List Style
iconStyles =
    [ Css.position Css.absolute
    , Css.backgroundColor Css.transparent
    , Css.padding (Css.px 0)
    , Css.borderColor (Css.rgba 0 0 0 0)
    , Css.border (Css.px 0)
    , Css.top (Css.pct 50)
    , Css.left (Css.px 0)
    , Css.marginLeft (Grid.calc Grid.grid Grid.divide -1)
    , Css.transform (Css.translate2 (Css.pct 0) (Css.pct -50))
    ]



-- MODIFIERS


onClick : msg -> Config msg -> Config msg
onClick msg (Config config) =
    Config { config | onClick = Just msg }
