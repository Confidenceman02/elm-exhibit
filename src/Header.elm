module Header exposing (example, home, navBottomBorder, navHeight, session, view)

import Author exposing (Author)
import Components.Button as Button
import Components.ElmLogo as ElmLogo
import Components.GithubLogo as GithubLogo
import Components.Link as Link
import Css as Css
import Html.Styled as Styled exposing (a, div, h1, span, text)
import Html.Styled.Attributes as StyledAttribs exposing (href)
import Package exposing (Package)
import Session exposing (Session)
import Styles.Color exposing (exColorSky600, exColorSky700, exColorWhite)
import Styles.Common exposing (absoluteCenterHorizontal, absoluteCenterVertical)


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


type GitAuth
    = LoggedIn
    | LoggedOut
    | None


type alias Configuration =
    { variant : Variant
    , session : Maybe Session
    }


type alias PackageConfiguration =
    { owner : String
    , repo : String
    , version : String
    }


defaultConfig : Configuration
defaultConfig =
    { variant = Home
    , session = Nothing
    }



-- CONFIG BUILDERS


example : Author -> Package -> Config
example author package =
    Config { defaultConfig | variant = Example author package }


session : Session -> Config -> Config
session sesh (Config config) =
    Config { config | session = Just sesh }


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
            , Css.height (Css.px navHeight)
            ]
        ]
        [ div [ StyledAttribs.css absoluteCenterHorizontal ]
            [ nav config

            --, div [ StyledAttribs.css ([ Css.top (Css.px 0), Css.right (Css.px 0) ] ++ absoluteCenterVertical) ]
            --    [ GithubLogo.view GithubLogo.default ]
            ]
        , sessionActionView
        ]


sessionActionView : Styled.Html msg
sessionActionView =
    div [ StyledAttribs.css ([ Css.top (Css.px 0), Css.right (Css.px 2) ] ++ absoluteCenterVertical) ]
        [ Button.view (Button.wrapper [ GithubLogo.view GithubLogo.default ]) "Sign in with github" ]


nav : Configuration -> Styled.Html msg
nav config =
    div
        [ StyledAttribs.css
            [ Css.color exColorWhite
            , Css.displayFlex
            , Css.alignItems Css.center
            ]
        ]
        [ shadowHomeLink
        , case config.variant of
            Example author package ->
                exampleTitle author package

            _ ->
                text ""
        , homeLink
        ]


homeLink : Styled.Html msg
homeLink =
    div [ StyledAttribs.css [ Css.position Css.absolute ] ]
        [ Link.view (Link.default |> Link.href "/")
            (Link.htmlBody
                [ div [ StyledAttribs.css [ Css.displayFlex, Css.alignItems Css.center ] ]
                    [ ElmLogo.view <| ElmLogo.static
                    , appTitle
                    ]
                ]
            )
        ]


shadowHomeLink : Styled.Html msg
shadowHomeLink =
    div [ StyledAttribs.css [ Css.displayFlex, Css.marginRight (Css.px 32), Css.visibility Css.hidden ] ]
        [ div [ StyledAttribs.css [ Css.displayFlex, Css.alignItems Css.center ] ]
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
