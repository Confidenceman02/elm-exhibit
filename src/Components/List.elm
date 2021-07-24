module Components.List exposing (default, items, view)

import Css
import Html.Styled as Styled exposing (li)
import Html.Styled.Attributes as StyledAttribs
import Html.Styled.Keyed as Keyed


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { items : List (Styled.Html msg)
    }


defaults : Configuration msg
defaults =
    { items = [] }


default : Config msg
default =
    Config defaults



-- MODIFIERS


items : List (Styled.Html msg) -> Config msg -> Config msg
items listItems (Config config) =
    Config { config | items = listItems }


view : Config msg -> Styled.Html msg
view (Config config) =
    Keyed.node "ul"
        [ StyledAttribs.css [ Css.listStyle Css.none, Css.padding (Css.px 0), Css.margin (Css.px 0) ] ]
        (List.indexedMap (\idx item -> ( String.fromInt idx ++ "ListItem", li [] [ item ] )) config.items)
