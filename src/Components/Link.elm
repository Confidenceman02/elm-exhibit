module Components.Link exposing (default, href, htmlBody, onHoverEffect, stringBody, stringBodyDefault, view)

import Css
import Html.Styled as Styled exposing (a, text)
import Html.Styled.Attributes as StyledAttribs
import Styles.Color exposing (exColorSky700, exColorSky800)


type Config
    = Config Configuration


type StringBodyConfig
    = StringBodyConfig StringBodyConfiguration


type alias StringBodyConfiguration =
    { onHoverEffect : Bool
    }


type alias Configuration =
    { variant : Variant
    , href : String
    }


type Content msg
    = StringBody String StringBodyConfig
    | HtmlBody (List (Styled.Html msg))


stringBodyDefaults : StringBodyConfiguration
stringBodyDefaults =
    { onHoverEffect = False
    }


stringBodyDefault : StringBodyConfig
stringBodyDefault =
    StringBodyConfig stringBodyDefaults


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



-- STRINGBODY MODIFIERS


onHoverEffect : Bool -> StringBodyConfig -> StringBodyConfig
onHoverEffect pred (StringBodyConfig config) =
    StringBodyConfig { config | onHoverEffect = pred }



-- MODIFIERS


htmlBody : List (Styled.Html msg) -> Content msg
htmlBody content =
    HtmlBody content


stringBody : String -> StringBodyConfig -> Content msg
stringBody content config =
    StringBody content config


href : String -> Config -> Config
href hrefString (Config config) =
    Config { config | href = hrefString }


view : Config -> Content msg -> Styled.Html msg
view (Config config) content =
    case content of
        HtmlBody htmlContent ->
            a [ StyledAttribs.href config.href, StyledAttribs.css [ Css.color Css.inherit, Css.textDecoration Css.none ] ] htmlContent

        StringBody stringContent (StringBodyConfig strConfig) ->
            let
                hoverStyles =
                    if strConfig.onHoverEffect then
                        [ Css.color exColorSky800 ]

                    else
                        []
            in
            a
                [ StyledAttribs.href config.href
                , StyledAttribs.css
                    [ Css.textDecoration Css.none
                    , Css.color exColorSky700
                    , Css.hover hoverStyles
                    ]
                ]
                [ text stringContent ]
