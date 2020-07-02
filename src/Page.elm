module Page exposing (view)

import Browser exposing (Document)
import Html.Styled as Styled


view : { title : String, content : Styled.Html msg } -> { title : String, body : List (Styled.Html msg) }
view { title, content } =
    { title = title
    , body = [ content ]
    }
