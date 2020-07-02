module Styles.Font exposing (fontSizeH2)

import Css as Css


defaultBrowserFontSize : Float
defaultBrowserFontSize =
    16


idealTitleSize : Float
idealTitleSize =
    26


fontSizeH2 : Css.Rem
fontSizeH2 =
    Css.rem (idealTitleSize / defaultBrowserFontSize)
