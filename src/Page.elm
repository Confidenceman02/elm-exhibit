module Page exposing (Page(..), view)

import Author exposing (Author)
import Header as Header
import Html.Styled as Styled exposing (text)
import Package exposing (Package)
import Session exposing (Session)


type Page msg
    = Home
    | Exhibit Author Package Session (Header.Msg -> msg) Header.State
    | Author Author Session (Header.Msg -> msg) Header.State
    | AuthGithubRedirect


view : Page msg -> { title : String, content : Styled.Html msg } -> { title : String, body : List (Styled.Html msg) }
view page { title, content } =
    { title = title
    , body = viewHeader page :: [ content ]
    }


viewHeader : Page msg -> Styled.Html msg
viewHeader page =
    case page of
        Exhibit author package session toHeaderMsg headerState ->
            -- This looks weird but the Header has its own msgs it can dispatch so we need to
            -- catch those in the relevant Page. The Exhibit page in this case.
            Styled.map toHeaderMsg (Header.view (Header.exhibit author package |> Header.session session |> Header.state headerState))

        Author author session toHeaderMsg headerState ->
            -- This looks weird but the Header has its own msgs it can dispatch so we need to
            -- catch those in the relevant Page. The Author page in this case.
            Styled.map toHeaderMsg (Header.view (Header.author author |> Header.session session |> Header.state headerState))

        Home ->
            text ""

        AuthGithubRedirect ->
            text ""
