module Pages.Author exposing (Effect(..), Model, Msg, init, subscriptions, toHeaderMsg, update, view)

import Author exposing (Author)
import Context exposing (Context)
import Effect
import Header
import Html.Styled as Styled exposing (text)


type Msg
    = HeaderMsg Header.Msg


toHeaderMsg : Header.Msg -> Msg
toHeaderMsg =
    HeaderMsg


type Effect
    = HeaderEffect Header.HeaderEffect


type alias Model =
    { context : Context
    , author : Author
    , headerState : Header.State
    }


init : Author -> Context -> Model
init author context =
    { context = context
    , author = author
    , headerState = Header.initState
    }


view : Model -> { title : String, content : Styled.Html msg }
view model =
    { title = Author.toString model.author
    , content = text "This is the author page bro"
    }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg, Effect.Effect Effect )
update msg model =
    case msg of
        HeaderMsg headerMsg ->
            let
                ( headerState, headerCmds, headerEffect ) =
                    Header.update model.headerState headerMsg
            in
            ( { model | headerState = headerState }, Cmd.map HeaderMsg headerCmds, Effect.map HeaderEffect headerEffect )


subscriptions : Model -> Sub Msg
subscriptions m =
    Sub.map HeaderMsg (Header.subscriptions m.headerState)
