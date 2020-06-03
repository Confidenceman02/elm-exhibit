module Header exposing (home, navHeight, package, view)

import Api as Api
import Css as Css
import Html.Styled as Styled exposing (div, h1, span, text)
import Html.Styled.Attributes as StyledAttribs
import Svg.Styled exposing (polygon, svg)
import Svg.Styled.Attributes exposing (fill, height, points, viewBox)


navHeight : Float
navHeight =
    64


type Config
    = Config Configuration


type Variant
    = Package Api.Package
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


package : Api.Package -> Config
package pConfig =
    Config { defaultConfig | variant = Package pConfig }


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
            , Css.backgroundColor (Css.hex "#5FABDC")
            , Css.overflowX Css.hidden
            ]
        ]
        [ nav config ]


nav : Configuration -> Styled.Html msg
nav config =
    div
        [ StyledAttribs.css
            [ Css.color (Css.hex "#FFFFFF")
            , Css.maxWidth (Css.px 920)
            , Css.height (Css.px navHeight)
            , Css.margin2 (Css.px 0) Css.auto
            , Css.displayFlex
            , Css.alignItems Css.center
            ]
        ]
        [ homeLink
        , if isPackage config.variant then
            packageTitle config

          else
            text ""
        ]


homeLink : Styled.Html msg
homeLink =
    div [ StyledAttribs.css [ Css.textDecoration Css.none, Css.marginRight (Css.px 32), Css.displayFlex, Css.alignItems Css.center ] ] [ elmLogo, appTitle ]


packageTitle : Configuration -> Styled.Html msg
packageTitle config =
    h1 []
        [ text "Confidenceman02"
        , span [ StyledAttribs.css [ Css.margin2 (Css.px 0) (Css.px 10) ] ] [ text "/" ]
        , text "elm-animate-height"
        , span [ StyledAttribs.css [ Css.margin2 (Css.px 0) (Css.px 10) ] ] [ text "/" ]
        , text "2.0.1"
        ]


appTitle : Styled.Html msg
appTitle =
    div [ StyledAttribs.css [ Css.paddingLeft (Css.px 8) ] ]
        [ div [ StyledAttribs.css [ Css.lineHeight (Css.px 24), Css.fontSize (Css.px 28) ] ] [ text "elm" ]
        , div [ StyledAttribs.css [ Css.fontSize (Css.px 16) ] ] [ text "exhibit" ]
        ]


elmLogo : Styled.Html msg
elmLogo =
    svg [ height "32", viewBox "0 0 600 600" ]
        [ polygon [ fill "currentColor", points "0, 20 280, 300 0,580" ] []
        , polygon [ fill "currentColor", points "20,600 300,320 580,600" ] []
        , polygon [ fill "currentColor", points "320,0 600,0 600,280" ] []
        , polygon [ fill "currentColor", points "20,0 280,0 402,122 142,122" ] []
        , polygon [ fill "currentColor", points "170,150 430,150 300,280" ] []
        , polygon [ fill "currentColor", points "320,300 450,170 580,300 450,430" ] []
        , polygon [ fill "currentColor", points "470,450 600,320 600,580" ] []
        ]



-- HELPERS


isPackage : Variant -> Bool
isPackage v =
    case v of
        Package _ ->
            True

        _ ->
            False
