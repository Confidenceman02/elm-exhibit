module Pages.Home exposing (Msg, view)

import Html.Styled as Styled exposing (text)


type Msg
    = Nothing


view : { title : String, content : Styled.Html msg }
view =
    { title = "Home"
    , content = text "This is the home page bro"
    }
