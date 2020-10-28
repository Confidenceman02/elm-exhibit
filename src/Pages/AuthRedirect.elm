module Pages.AuthRedirect exposing (Msg, view)

import Html.Styled as Styled exposing (text)


type Msg
    = None


view : { title : String, content : Styled.Html msg }
view =
    { title = "auth redirect", content = text "Hello Auth Redirect" }
