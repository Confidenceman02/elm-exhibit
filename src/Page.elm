module Page exposing (Page(..), view)

import Author exposing (Author)
import Exhibit exposing (Exhibit)
import Header as Header
import Html.Styled as Styled exposing (text)
import Session exposing (Session)


type Page msg
    = Home
    | Exhibit Author Exhibit Session (Header.Msg -> msg) Header.State
    | AuthorExhibits Author Session (Header.Msg -> msg) Header.State
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
            Styled.map toHeaderMsg (Header.view (Header.exhibit author package |> Header.state headerState) session)

        AuthorExhibits author session toHeaderMsg headerState ->
            -- This looks weird but the Header has its own msgs it can dispatch so we need to
            -- catch those in the relevant Page. The Author page in this case.
            Styled.map toHeaderMsg (Header.view (Header.author author |> Header.state headerState) session)

        Home ->
            text ""

        AuthGithubRedirect ->
            text ""
