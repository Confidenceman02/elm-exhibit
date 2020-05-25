module Main exposing (..)

import Browser as Browser exposing (Document)
import Browser.Navigation as Navigation
import Css as Css
import Html.Styled as Styled exposing (div, h1, span, text)
import Html.Styled.Attributes as StyledAttribs
import Svg.Styled as SvgStyled exposing (polygon, svg)
import Svg.Styled.Attributes exposing (fill, height, points, viewBox)
import Url


type Msg
    = Noop


init : {} -> Url.Url -> Navigation.Key -> ( {}, Cmd Msg )
init _ _ _ =
    ( {}, Cmd.none )


view : {} -> Document Msg
view _ =
    { title = "Elm Exhibit"
    , body = [ header ] |> List.map Styled.toUnstyled
    }


header : Styled.Html Msg
header =
    div
        [ StyledAttribs.css
            [ Css.width <| Css.calc (Css.pct 100) Css.minus (Css.px 40)
            , Css.paddingLeft (Css.px 20)
            , Css.paddingRight (Css.px 20)
            , Css.backgroundColor (Css.hex "#5FABDC")
            , Css.overflowX Css.hidden
            ]
        ]
        [ nav ]


nav : Styled.Html Msg
nav =
    div
        [ StyledAttribs.css
            [ Css.color (Css.hex "#FFFFFF")
            , Css.maxWidth (Css.px 920)
            , Css.height (Css.px 64)
            , Css.margin2 (Css.px 0) Css.auto
            , Css.displayFlex
            , Css.alignItems Css.center
            ]
        ]
        [ homeLink, packageTitle ]


homeLink : Styled.Html Msg
homeLink =
    div [ StyledAttribs.css [ Css.textDecoration Css.none, Css.marginRight (Css.px 32), Css.displayFlex, Css.alignItems Css.center ] ] [ elmLogo, appTitle ]


packageTitle : Styled.Html Msg
packageTitle =
    h1 []
        [ text "Confidenceman02"
        , span [ StyledAttribs.css [ Css.margin2 (Css.px 0) (Css.px 10) ] ] [ text "/" ]
        , text "elm-animate-height"
        , span [ StyledAttribs.css [ Css.margin2 (Css.px 0) (Css.px 10) ] ] [ text "/" ]
        , text "2.0.1"
        ]


appTitle : Styled.Html Msg
appTitle =
    div [ StyledAttribs.css [ Css.paddingLeft (Css.px 8) ] ]
        [ div [ StyledAttribs.css [ Css.lineHeight (Css.px 24), Css.fontSize (Css.px 28) ] ] [ text "elm" ]
        , div [ StyledAttribs.css [ Css.fontSize (Css.px 16) ] ] [ text "exhibit" ]
        ]


elmLogo : Styled.Html Msg
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


update : Msg -> {} -> ( {}, Cmd Msg )
update _ _ =
    ( {}, Cmd.none )


subscriptions : {} -> Sub Msg
subscriptions _ =
    Sub.none


main : Program {} {} Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = \_ -> Noop
        , onUrlChange = \_ -> Noop
        }
