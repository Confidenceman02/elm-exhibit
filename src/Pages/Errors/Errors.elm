module Pages.Errors.Errors exposing (bummer, content, oops, ourBad, view, weird)

import Components.ElmLogo as ElmLogo
import Components.Heading as Heading
import Css
import Html.Styled as Styled exposing (div, span)
import Styles.Color as Color
import Styles.Grid as Grid
import Svg.Styled.Attributes as StyledAttribs


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { variant : Variant
    , content : List (Styled.Html msg)
    }


type Variant
    = Bummer
    | Weird


defaults : Configuration msg
defaults =
    { variant = Bummer
    , content = []
    }


bummer : Config msg
bummer =
    Config
        { defaults
            | variant = Bummer
        }


weird : Config msg
weird =
    Config
        { defaults
            | variant = Weird
        }



-- MODIFIERS


content : List (Styled.Html msg) -> Config msg -> Config msg
content c (Config config) =
    Config { config | content = c }


view : Config msg -> Styled.Html msg
view (Config config) =
    let
        resolveVariant =
            case config.variant of
                Bummer ->
                    "Bummer.."

                Weird ->
                    "Weird.."
    in
    div
        [ StyledAttribs.css
            [ Css.padding Grid.grid
            ]
        ]
        [ div
            [ StyledAttribs.css
                [ Css.displayFlex
                , Css.alignItems Css.baseline
                ]
            ]
            [ ElmLogo.view (ElmLogo.static |> ElmLogo.color (ElmLogo.CustomColor Color.exColorOfficialYellow))
            , span [ StyledAttribs.css [ Css.marginLeft Grid.grid ] ]
                [ Heading.view
                    (Heading.h1
                        |> Heading.overrides [ StyledAttribs.css [ Css.fontWeight (Css.int 400) ] ]
                        |> Heading.inline True
                    )
                    resolveVariant
                ]
            ]
        , div [] config.content
        ]
