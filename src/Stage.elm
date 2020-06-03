module Stage exposing (..)

import Css as Css
import Css.Transitions as CssTransition
import Header as Header
import Html.Styled as Styled exposing (div, text)
import Html.Styled.Attributes as StyledAttribs


view : Styled.Html msg -> Styled.Html msg
view content =
    stageWrapper
        [ sliderLeft, menu, sliderRight ]


mainStage : Styled.Html msg
mainStage =
    div [ StyledAttribs.css [ Css.displayFlex, Css.position Css.absolute ] ] [ menu, package ]


package : Styled.Html msg
package =
    div [] [ text "PACKAGE" ]


menu : Styled.Html msg
menu =
    div [ StyledAttribs.css [ Css.width (Css.pct 100) ] ] [ menuContent ]


menuContent : Styled.Html msg
menuContent =
    div [ StyledAttribs.css [ Css.position Css.absolute, Css.left (Css.pct 50), Css.top (Css.pct 50) ] ] [ text "MENU" ]


sliderLeft : Styled.Html msg
sliderLeft =
    div [ StyledAttribs.css [ Css.position Css.absolute, Css.height (Css.pct 100), Css.left (Css.px 0) ] ] [ package ]


sliderRight : Styled.Html msg
sliderRight =
    div [ StyledAttribs.css [ Css.position Css.absolute, Css.height (Css.pct 100), Css.right (Css.px 0) ] ] [ text "SLIDER RIGHT" ]


stageWrapper : List (Styled.Html msg) -> Styled.Html msg
stageWrapper content =
    div
        [ StyledAttribs.css
            [ Css.top (Css.px Header.navHeight)
            , Css.bottom (Css.px 0)
            , Css.position Css.fixed
            , Css.width (Css.pct 100)
            ]
        ]
        content
