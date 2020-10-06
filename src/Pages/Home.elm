module Pages.Home exposing (Model, Msg, init, toContext, view)

import Context exposing (Context)
import Html.Styled as Styled exposing (text)


type Msg
    = Nothing


type alias Model =
    { context : Context
    }


toContext : Model -> Context
toContext model =
    model.context


init : Context -> Model
init context =
    { context = context
    }


view : { title : String, content : Styled.Html msg }
view =
    { title = "Home"
    , content = text "This is the home page bro"
    }
