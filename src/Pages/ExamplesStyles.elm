module Pages.ExamplesStyles exposing (centerWrapper)

import Css
import Html.Styled exposing (Attribute)
import Styles.Grid as Grid
import Styles.Transition as Transition
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
        ([ Css.position Css.absolute
         , Css.transform (Css.translate2 (Css.pct -50) (Css.pct 0))
         , Css.marginTop (Grid.calc Grid.grid Grid.multiply 1.5)
         ]
            ++ Transition.left (Css.pct resolveLeft)
        )
