module Components.Button exposing
    ( Icon(..)
    , Orientation(..)
    , backgroundColor
    , hoverColor
    , icon
    , iconDefault
    , iconLabel
    , iconOrientation
    , onClick
    , padding
    , secondary
    , view
    , wrapper
    )

import Css exposing (Style)
import Html.Styled as Styled exposing (button, div, span, text)
import Html.Styled.Attributes as StyledAttribs
import Html.Styled.Events as Events
import Styles.Color exposing (exColorMulch600)
import Styles.Grid as Grid
import Styles.Transition as Transition
import Styles.Typography exposing (exTypographyButtonSecondaryFontSize)
import Svg.Styled exposing (polygon, svg)
import Svg.Styled.Attributes as SvgAttribs exposing (height, points, viewBox)


type Variant msg
    = Secondary
    | IconButton Icon
    | Wrapper (List (Styled.Html msg))


type Icon
    = Triangle IconConfig


type Config msg
    = Config (Configuration msg)


type IconConfig
    = IconConfig IconConfiguration


type alias IconConfiguration =
    { orientation : Orientation
    , label : Maybe String
    }


type alias Configuration msg =
    { variant : Variant msg
    , onClick : Maybe msg
    , padding : Bool
    , backgroundColor : Maybe Css.Color
    , hoverColor : Maybe Css.Color
    }


type Orientation
    = RightFacing
    | LeftFacing


defaults : Configuration msg
defaults =
    { variant = Secondary
    , onClick = Nothing
    , padding = True
    , backgroundColor = Nothing
    , hoverColor = Nothing
    }


iconConfigDefaults : IconConfiguration
iconConfigDefaults =
    { orientation = RightFacing
    , label = Nothing
    }


secondary : Config msg
secondary =
    Config { defaults | variant = Secondary }


backgroundColor : Css.Color -> Config msg -> Config msg
backgroundColor c (Config config) =
    Config { config | backgroundColor = Just c }


padding : Bool -> Config msg -> Config msg
padding p (Config config) =
    Config { config | padding = p }


hoverColor : Css.Color -> Config msg -> Config msg
hoverColor c (Config config) =
    Config { config | hoverColor = Just c }


iconDefault : IconConfig
iconDefault =
    IconConfig iconConfigDefaults


iconOrientation : Orientation -> IconConfig -> IconConfig
iconOrientation orientation (IconConfig config) =
    IconConfig { config | orientation = orientation }


iconLabel : String -> IconConfig -> IconConfig
iconLabel label (IconConfig config) =
    IconConfig { config | label = Just label }


icon : Icon -> Config msg
icon iconType =
    Config { defaults | variant = IconButton iconType }


wrapper : List (Styled.Html msg) -> Config msg
wrapper content =
    Config { defaults | variant = Wrapper content }


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

                Wrapper _ ->
                    wrapperStyles config

        resolveButtonBody =
            case config.variant of
                Secondary ->
                    [ span
                        [ StyledAttribs.css
                            [ Css.fontSize exTypographyButtonSecondaryFontSize
                            , Css.property "padding" <| calc
                            , Css.height (Css.pct 100)
                            ]
                        ]
                        [ text label ]
                    ]

                IconButton (Triangle (IconConfig iconConfig)) ->
                    [ triangle iconConfig ]

                Wrapper content ->
                    content
    in
    button
        ([ StyledAttribs.type_ "button", StyledAttribs.css resolveStyles ] ++ eventAttribs)
        resolveButtonBody


triangle : IconConfiguration -> Styled.Html msg
triangle iconConfig =
    let
        resolveDeg =
            case iconConfig.orientation of
                RightFacing ->
                    180

                _ ->
                    0

        resolvedSvg =
            svg
                [ height "32"
                , viewBox "0 0 150 300"
                , SvgAttribs.css <|
                    ([ Css.fill Css.currentColor
                     ]
                        ++ Transition.transform (Css.rotate <| Css.deg resolveDeg)
                    )
                ]
                [ polygon [ points "0, 150 150, 0 150,300" ] [] ]
    in
    case iconConfig.label of
        Just label ->
            div [ StyledAttribs.css [ Css.displayFlex, Css.alignItems Css.center ] ]
                [ span
                    [ StyledAttribs.css
                        [ Css.marginRight (Css.px 12)
                        ]
                    ]
                    [ text label ]
                , resolvedSvg
                ]

        _ ->
            resolvedSvg



-- STYLES


secondaryStyles : List Style
secondaryStyles =
    [ Css.displayFlex
    , Css.position Css.relative
    , Css.color exColorMulch600
    , Css.fontWeight (Css.int 700)
    , Css.boxSizing Css.borderBox
    , Css.backgroundColor Css.transparent
    , Css.borderColor (Css.rgba 0 0 0 0)
    , Css.hover [ Css.backgroundColor (Css.hex "#f0f1f4") ] -- $kz-color-wisteria-100
    , Css.border (Css.px 2)
    , Css.padding (Css.px 0)
    , Css.borderRadius (Css.px 6)
    ]


iconStyles : List Style
iconStyles =
    [ Css.displayFlex
    , Css.backgroundColor Css.transparent
    , Css.padding (Css.px 0)
    , Css.borderColor (Css.rgba 0 0 0 0)
    , Css.border (Css.px 0)
    , Css.color Css.inherit
    ]


wrapperStyles : Configuration msg -> List Style
wrapperStyles config =
    let
        resolvePadding =
            if config.padding then
                Css.property "padding" (Css.calc Grid.halfGrid Css.minus (Css.px 2)).value

            else
                Css.padding (Css.px 0)

        resolveBackgroundColor =
            case config.backgroundColor of
                Just c ->
                    [ Css.backgroundColor c ]

                _ ->
                    []

        resolveHoverColor =
            case config.hoverColor of
                Just c ->
                    [ Css.hover [ Css.backgroundColor c ] ]

                _ ->
                    [ Css.hover [ Css.backgroundColor (Css.rgba 55 55 55 0.1) ] ]
    in
    [ Css.backgroundColor Css.transparent
    , Css.border (Css.px 0)
    , Css.borderRadius (Css.px 6)
    , resolvePadding
    , Css.position Css.relative
    ]
        ++ resolveBackgroundColor
        ++ resolveHoverColor



-- MODIFIERS


onClick : msg -> Config msg -> Config msg
onClick msg (Config config) =
    Config { config | onClick = Just msg }
