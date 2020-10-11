module Components.Heading exposing (h1, h4, inline, overrides, view)

import Css
import Html.Styled as Styled exposing (text)
import Styles.Typography exposing (exTypographyHeading1FontSize, exTypographyHeading1FontWeight, exTypographyHeading4FontSize, exTypographyHeading4FontWeight)
import Svg.Styled.Attributes as StyledAttribs


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { variant : Variant
    , styledOverrides : Maybe (List (Styled.Attribute msg))
    , inline : Bool
    }



-- DEFAULTS


defaults : Configuration msg
defaults =
    { variant = Heading4
    , styledOverrides = Nothing
    , inline = False
    }



-- VARIANT


type Variant
    = Heading1
    | Heading4


h1 : Config msg
h1 =
    Config { defaults | variant = Heading1 }


h4 : Config msg
h4 =
    Config { defaults | variant = Heading4 }



-- MODIFIERS


overrides : List (Styled.Attribute msg) -> Config msg -> Config msg
overrides o (Config config) =
    Config { config | styledOverrides = Just o }


inline : Bool -> Config msg -> Config msg
inline predicate (Config config) =
    Config { config | inline = predicate }


view : Config msg -> String -> Styled.Html msg
view (Config config) txt =
    let
        resolveOverrides =
            case config.styledOverrides of
                Just o ->
                    o

                _ ->
                    []
    in
    mapVariantToTag config (mapVariantToStyles config ++ resolveOverrides) [ text txt ]



-- HELPERS


mapVariantToTag : Configuration msg -> (List (Styled.Attribute msg) -> List (Styled.Html msg) -> Styled.Html msg)
mapVariantToTag config =
    case config.variant of
        Heading1 ->
            Styled.h1

        Heading4 ->
            Styled.h4


mapVariantToStyles : Configuration msg -> List (Styled.Attribute msg)
mapVariantToStyles config =
    let
        withInline styles =
            if config.inline then
                -- adding styles like this avoids messing around with the overrides. Its weird..
                [ Css.margin (Css.px 0) ] ++ styles

            else
                styles
    in
    case config.variant of
        Heading1 ->
            [ StyledAttribs.css
                ([ Css.fontWeight (Css.int exTypographyHeading1FontWeight)
                 , Css.fontSize exTypographyHeading1FontSize
                 ]
                    |> withInline
                )
            ]

        Heading4 ->
            [ StyledAttribs.css [ Css.fontWeight (Css.int exTypographyHeading4FontWeight), Css.fontSize exTypographyHeading4FontSize ] ]
