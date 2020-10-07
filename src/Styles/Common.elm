module Styles.Common exposing (absoluteCenterHorizontal)

import Css exposing (Style)


absoluteCenterHorizontal : List Style
absoluteCenterHorizontal =
    [ Css.position Css.absolute, Css.transform (Css.translate2 (Css.pct -50) (Css.pct 0)), Css.left (Css.pct 50) ]
