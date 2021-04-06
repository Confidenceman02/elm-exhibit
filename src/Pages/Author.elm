module Pages.Author exposing (Model, Msg, init, toHeaderMsg, view)

import Author exposing (Author)
import Context exposing (Context)
import Header
import Html.Styled as Styled exposing (text)


type Msg
    = Nothing
    | HeaderMsg Header.Msg


toHeaderMsg : Header.Msg -> Msg
toHeaderMsg =
    HeaderMsg


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
