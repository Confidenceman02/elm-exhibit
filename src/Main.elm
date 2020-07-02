module Main exposing (..)

import Api as Api
import Browser as Browser exposing (Document)
import Browser.Navigation as Navigation
import Header as Header
import Html.Styled as Styled
import Pages.Examples as ExamplesPage
import Url


type Msg
    = Noop
    | Example ExamplesPage.Msg


init : {} -> Url.Url -> Navigation.Key -> ( {}, Cmd Msg )
init _ _ _ =
    ( {}, Cmd.none )


view : {} -> Document Msg
view _ =
    { title = "Elm Exhibit"
    , body = [ header, Styled.map Example ExamplesPage.view ] |> List.map Styled.toUnstyled
    }


header : Styled.Html msg
header =
    Header.view <| Header.package Api.hardCodedPackage


update : Msg -> {} -> ( {}, Cmd Msg )
update msg _ =
    case msg of
        Example packageMsg ->
            ( {}, Cmd.none )

        _ ->
            ( {}, Cmd.none )


subscriptions : {} -> Sub Msg
subscriptions _ =
    Sub.none


main : Program {} {} Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = \_ -> Noop
        , onUrlChange = \_ -> Noop
        }
