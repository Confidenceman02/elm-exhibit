module MenuList.Divider exposing (view)

import Css
import Html.Styled as Styled exposing (div)
import Html.Styled.Attributes as StyledAttribs


view : Styled.Html msg
view =
    div
        [ StyledAttribs.css
            [ Css.display Css.block
            , Css.height (Css.px 0)
            , Css.marginTop (Css.px 8)
            , Css.marginBottom (Css.px 8)
            , Css.borderTop3 (Css.px 1) Css.solid (Css.hex "#E6E6E6")
            ]
        ]
        []
