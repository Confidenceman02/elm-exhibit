module Components.Paragraph exposing (Style(..), default, inline, overrides, style, view)

import Css
import Html.Styled as Styled exposing (p)
import Styles.Typography exposing (exTypographyParagraphBodyBoldFontSize, exTypographyParagraphBodyBoldFontWeight, exTypographyParagraphBodyFontSize, exTypographyParagraphIntroFontSize)
import Svg.Styled.Attributes as StyledAttribs


type Config
    = Config Configuration


type alias Configuration =
    { styledOverrides : Maybe (List Css.Style)
    , inline : Bool
    , style : Style
    }



-- DEFAULTS


default : Config
default =
    Config defaults


defaults : Configuration
defaults =
    { styledOverrides = Nothing
    , inline = False
    , style = Body
    }


type Style
    = Body
    | BodyBold
    | Intro



-- MODIFIERS


overrides : List Css.Style -> Config -> Config
overrides o (Config config) =
    Config { config | styledOverrides = Just o }


inline : Bool -> Config -> Config
inline predicate (Config config) =
    Config { config | inline = predicate }


style : Style -> Config -> Config
style s (Config config) =
    Config { config | style = s }


view : Config -> List (Styled.Html msg) -> Styled.Html msg
view (Config config) content =
    let
        resolveOverrides =
            case config.styledOverrides of
                Just o ->
                    o

                _ ->
                    []

        withStyle styles =
            case config.style of
                Intro ->
                    [ Css.fontSize exTypographyParagraphIntroFontSize ] ++ styles

                Body ->
                    [ Css.fontSize exTypographyParagraphBodyFontSize ] ++ styles

                BodyBold ->
                    [ Css.fontSize exTypographyParagraphBodyBoldFontSize, Css.fontWeight (Css.int exTypographyParagraphBodyBoldFontWeight) ] ++ styles

        withInline styles =
            if config.inline then
                [ Css.display Css.inlineBlock, Css.margin (Css.px 0) ] ++ styles

            else
                styles
    in
    p
        [ StyledAttribs.css
            (resolveOverrides
                |> withStyle
                |> withInline
            )
        ]
        content
