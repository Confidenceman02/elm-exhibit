module Page exposing (Page(..), view)

import Author exposing (Author)
import Header as Header
import Html.Styled as Styled exposing (text)
import Package exposing (Package)
import Session exposing (Session)


type Page msg
    = Home
    | Examples Author Package Session (Header.Msg -> msg) Header.State
    | AuthGithubRedirect


view : Page msg -> { title : String, content : Styled.Html msg } -> { title : String, body : List (Styled.Html msg) }
view page { title, content } =
    { title = title
    , body = viewHeader page :: [ content ]
    }


viewHeader : Page msg -> Styled.Html msg
viewHeader page =
    case page of
        Examples author package session toHeaderMsg headerState ->
            -- This looks weird but the Header has its own msgs it can dispatch so we need to
            -- catch those in the relevant Page. The Examples page in this case.
            Styled.map toHeaderMsg (Header.view (Header.example author package |> Header.session session |> Header.state headerState))

        Home ->
            text ""

        AuthGithubRedirect ->
            text ""
