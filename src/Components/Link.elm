module Components.Link exposing (default, href, htmlBody, stringBody, view)

import Css
import Html.Styled as Styled exposing (a, text)
import Html.Styled.Attributes as StyledAttribs
import Styles.Color exposing (exColorSky700)


type Config
    = Config Configuration


type alias Configuration =
    { variant : Variant
    , href : String
    }


type Content msg
    = StringBody String
    | HtmlBody (List (Styled.Html msg))


defaults : Configuration
defaults =
    { variant = Default
    , href = "*"
    }


default : Config
default =
    Config defaults



-- VARIANTS


type Variant
    = Default



-- MODIFIERS


htmlBody : List (Styled.Html msg) -> Content msg
htmlBody content =
    HtmlBody content


stringBody : String -> Content msg
stringBody content =
    StringBody content


href : String -> Config -> Config
href hrefString (Config config) =
    Config { config | href = hrefString }


view : Config -> Content msg -> Styled.Html msg
view (Config config) content =
    case content of
        HtmlBody htmlContent ->
            a [ StyledAttribs.href config.href, StyledAttribs.css [ Css.color Css.inherit, Css.textDecoration Css.none ] ] htmlContent

        StringBody stringContent ->
            a
                [ StyledAttribs.href config.href
                , StyledAttribs.css
                    [ Css.textDecoration Css.none, Css.color exColorSky700 ]
                ]
                [ text stringContent ]
