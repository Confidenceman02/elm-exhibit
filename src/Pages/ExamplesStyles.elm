module Pages.ExamplesStyles exposing (centerWrapper)

import Css
import Css.Transitions as Transitions
import Html.Styled exposing (Attribute)
import Styles.Grid as Grid
import Svg.Styled.Attributes as StyledAttribs


centerWrapper : Bool -> Attribute msg
centerWrapper center =
    let
        resolveLeft =
            if center then
                50

            else
                46
    in
    StyledAttribs.css
        [ Css.position Css.absolute
        , Css.left (Css.pct resolveLeft)
        , Css.transform (Css.translate2 (Css.pct -50) (Css.pct 0))
        , Css.marginTop (Grid.calc Grid.grid Grid.multiply 1.5)
        , Transitions.transition [ Transitions.left3 300 0 (Transitions.cubicBezier 0.16 0.68 0.43 0.99) ]
        ]
