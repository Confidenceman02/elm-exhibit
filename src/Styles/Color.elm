module Styles.Color exposing
    ( exColorBorder
    , exColorBurn500
    , exColorBurn600
    , exColorColt100
    , exColorColt200
    , exColorOfficialDarkBlue
    , exColorOfficialGreen
    , exColorOfficialLightBlue
    , exColorOfficialYellow
    , exColorSky600
    , exColorSky700
    , exColorWhite
    )

import Css exposing (Color)


exColorOfficialDarkBlue : Color
exColorOfficialDarkBlue =
    Css.hex "#5A6378"


exColorOfficialLightBlue : Color
exColorOfficialLightBlue =
    Css.hex "#60B5CC"


exColorOfficialGreen : Color
exColorOfficialGreen =
    Css.hex "#7FD13B"


exColorOfficialYellow : Color
exColorOfficialYellow =
    Css.hex "#F0AD00"


exColorWhite : Color
exColorWhite =
    Css.hex "#FFFFFF"


exColorBorder : Color
exColorBorder =
    Css.hex "#E6E6E6"


exColorColt100 : Color
exColorColt100 =
    Css.hex "#FBFBFB"


exColorColt200 : Color
exColorColt200 =
    Css.hex "#d6d6d6"


exColorBurn500 : Color
exColorBurn500 =
    exColorOfficialYellow


exColorBurn600 : Color
exColorBurn600 =
    Css.hex "#E8A500"


exColorSky600 : Color
exColorSky600 =
    Css.hex "#5FABDC"


exColorSky700 : Color
exColorSky700 =
    Css.hex "#5599C6"
