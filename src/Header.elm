module Header exposing (example, home, navBottomBorder, navHeight, view)

import Author exposing (Author)
import Components.ElmLogo as ElmLogo
import Css as Css
import Html.Styled as Styled exposing (a, div, h1, span, text)
import Html.Styled.Attributes as StyledAttribs exposing (href)
import Package exposing (Package)
import Styles.Color exposing (exColorSky600, exColorSky700, exColorWhite)


navHeight : Float
navHeight =
    64


navBottomBorder : Float
navBottomBorder =
    2


type Config
    = Config Configuration


type Variant
    = Example Author Package
    | Home


type alias Configuration =
    { variant : Variant
    }


type alias PackageConfiguration =
    { owner : String
    , repo : String
    , version : String
    }


defaultConfig : Configuration
defaultConfig =
    { variant = Home
    }



-- CONFIG BUILDERS


example : Author -> Package -> Config
example author package =
    Config { defaultConfig | variant = Example author package }


home : Config
home =
    Config { defaultConfig | variant = Home }


view : Config -> Styled.Html msg
view (Config config) =
    div
        [ StyledAttribs.css
            [ Css.width <| Css.calc (Css.pct 100) Css.minus (Css.px 40)
            , Css.paddingLeft (Css.px 20)
            , Css.paddingRight (Css.px 20)
            , Css.backgroundColor exColorSky600
            , Css.overflowX Css.hidden
            , Css.borderBottom3 (Css.px navBottomBorder) Css.solid exColorSky700
            ]
        ]
        [ nav config ]


nav : Configuration -> Styled.Html msg
nav config =
    div
        [ StyledAttribs.css
            [ Css.color exColorWhite
            , Css.maxWidth (Css.px 920)
            , Css.height (Css.px navHeight)
            , Css.margin2 (Css.px 0) Css.auto
            , Css.displayFlex
            , Css.alignItems Css.center
            , Css.justifyContent Css.center
            ]
        ]
        [ homeLink
        , case config.variant of
            Example author package ->
                exampleTitle author package

            _ ->
                text ""
        ]


homeLink : Styled.Html msg
homeLink =
    div [ StyledAttribs.css [ Css.displayFlex ] ]
        [ a
            [ href "/"
            , StyledAttribs.css
                [ Css.textDecoration Css.none
                , Css.marginRight (Css.px 32)
                , Css.displayFlex
                , Css.alignItems Css.center
                , Css.color Css.inherit
                ]
            ]
            [ ElmLogo.view <| ElmLogo.static
            , appTitle
            ]
        ]


exampleTitle : Author -> Package -> Styled.Html msg
exampleTitle author package =
    h1 [ StyledAttribs.css [ Css.fontWeight (Css.int 400) ] ]
        [ text (Author.toString author)
        , span [ StyledAttribs.css [ Css.margin2 (Css.px 0) (Css.px 10) ] ] [ text "/" ]
        , text (Package.toString package)
        ]


appTitle : Styled.Html msg
appTitle =
    div [ StyledAttribs.css [ Css.paddingLeft (Css.px 8) ] ]
        [ div [ StyledAttribs.css [ Css.lineHeight (Css.px 24), Css.fontSize (Css.px 28) ] ] [ text "elm" ]
        , div [ StyledAttribs.css [ Css.fontSize (Css.px 16) ] ] [ text "exhibit" ]
        ]



-- HELPERS


isExample : Variant -> Bool
isExample v =
    case v of
        Example _ _ ->
            True

        _ ->
            False
