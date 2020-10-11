module Styles.Typography exposing
    ( exTypographyButtonSecondaryFontSize
    , exTypographyHeading1FontSize
    , exTypographyHeading1FontWeight
    , exTypographyHeading4FontSize
    , exTypographyHeading4FontWeight
    , exTypographyParagraphBodyFontSize
    , exTypographyParagraphIntroFontSize
    )

import Css exposing (IntOrAuto, Rem)


exTypographyButtonSecondaryFontSize : Rem
exTypographyButtonSecondaryFontSize =
    Css.rem 1


exTypographyHeading1FontSize : Rem
exTypographyHeading1FontSize =
    Css.rem 2.25


exTypographyHeading1FontWeight : Int
exTypographyHeading1FontWeight =
    700


exTypographyHeading4FontSize : Rem
exTypographyHeading4FontSize =
    Css.rem 1.25


exTypographyHeading4FontWeight : Int
exTypographyHeading4FontWeight =
    700


exTypographyParagraphIntroFontSize : Rem
exTypographyParagraphIntroFontSize =
    Css.rem 1.25


exTypographyParagraphBodyFontSize : Rem
exTypographyParagraphBodyFontSize =
    Css.rem 1
