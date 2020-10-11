module Components.Paragraph exposing (Style(..), default, inline, overrides, style, view)

import Css
import Html.Styled as Styled exposing (p, text)
import Styles.Typography exposing (exTypographyParagraphBodyFontSize, exTypographyParagraphIntroFontSize)
import Svg.Styled.Attributes as StyledAttribs


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { styledOverrides : Maybe (List (Styled.Attribute msg))
    , inline : Bool
    , style : Style
    }



-- DEFAULTS


default : Config msg
default =
    Config defaults


defaults : Configuration msg
defaults =
    { styledOverrides = Nothing
    , inline = False
    , style = Body
    }


type Style
    = Body
    | Intro



-- MODIFIERS


overrides : List (Styled.Attribute msg) -> Config msg -> Config msg
overrides o (Config config) =
    Config { config | styledOverrides = Just o }


inline : Bool -> Config msg -> Config msg
inline predicate (Config config) =
    Config { config | inline = predicate }


style : Style -> Config msg -> Config msg
style s (Config config) =
    Config { config | style = s }


view : Config msg -> List (Styled.Html msg) -> Styled.Html msg
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

        withInline styles =
            if config.inline then
                [ Css.display Css.inlineBlock, Css.margin (Css.px 0) ] ++ styles

            else
                styles
    in
    p
        [ StyledAttribs.css
            ([]
                |> withStyle
                |> withInline
            )
        ]
        content
