module Page exposing (Page(..), view)

import Api
import Browser exposing (Document)
import Header as Header
import Html.Styled as Styled


type Page
    = Home
    | Examples


view : Page -> { title : String, content : Styled.Html msg } -> { title : String, body : List (Styled.Html msg) }
view page { title, content } =
    { title = title
    , body = viewHeader page :: [ content ]
    }


viewHeader : Page -> Styled.Html msg
viewHeader page =
    case page of
        Examples ->
            Header.view (Header.example Api.hardCodedExamples)

        Home ->
            Header.view (Header.example Api.hardCodedExamples)
