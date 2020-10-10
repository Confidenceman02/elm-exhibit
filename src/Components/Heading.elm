module Components.Heading exposing (h4, view)

import Css
import Html.Styled as Styled exposing (text)
import Styles.Typography exposing (exTypographyHeadingFontSize, exTypographyHeadingFontWeight)
import Svg.Styled.Attributes as StyledAttribs


type Config
    = Config Configuration


type alias Configuration =
    { variant : Variant
    }



-- DEFAULTS


defaults : Configuration
defaults =
    { variant = Heading4
    }



-- VARIANT


type Variant
    = Heading4


h4 : Config
h4 =
    Config { defaults | variant = Heading4 }


view : Config -> String -> Styled.Html msg
view (Config config) txt =
    mapVariantToTag config.variant (mapVariantToStyles config.variant) [ text txt ]



-- HELPERS


mapVariantToTag : Variant -> (List (Styled.Attribute msg) -> List (Styled.Html msg) -> Styled.Html msg)
mapVariantToTag variant =
    case variant of
        Heading4 ->
            Styled.h4


mapVariantToStyles : Variant -> List (Styled.Attribute msg)
mapVariantToStyles variant =
    case variant of
        Heading4 ->
            [ StyledAttribs.css [ Css.fontWeight (Css.int exTypographyHeadingFontWeight), Css.fontSize exTypographyHeadingFontSize ] ]
