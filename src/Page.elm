module Page exposing (Page(..), view)

import Author exposing (Author)
import Header as Header
import Html.Styled as Styled exposing (text)
import Package exposing (Package)


type Page
    = Home
    | Examples Author Package


view : Page -> { title : String, content : Styled.Html msg } -> { title : String, body : List (Styled.Html msg) }
view page { title, content } =
    { title = title
    , body = viewHeader page :: [ content ]
    }


viewHeader : Page -> Styled.Html msg
viewHeader page =
    case page of
        Examples author package ->
            Header.view (Header.example author package)

        Home ->
            text ""
