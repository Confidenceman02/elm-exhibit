module Pages.Errors.Bummer exposing (view)

import Components.ElmLogo as ElmLogo
import Components.Heading as Heading
import Css
import Html.Styled as Styled exposing (div, span)
import Styles.Color as Color
import Styles.Grid as Grid
import Svg.Styled.Attributes as StyledAttribs


view : Styled.Html msg -> Styled.Html msg
view content =
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
                    "Bummer.."
                ]
            ]
        , content
        ]
