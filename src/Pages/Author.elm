module Pages.Author exposing (Effect(..), Model, Msg, init, subscriptions, toHeaderMsg, update, view)

import Author exposing (Author)
import Context exposing (Context)
import Css
import Effect
import Header
import Html.Styled as Styled exposing (div, main_, text)
import Html.Styled.Attributes as StyledAttribs
import LoadingPlaceholder.LoadingPlaceholder as LoadingPlaceholder
import Styles.Spacing exposing (exSpacingXxl)


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
    , content =
        main_
            []
            [ mainContentWrapper ]
    }


mainContentWrapper : Styled.Html msg
mainContentWrapper =
    div
        [ StyledAttribs.css
            [ Css.displayFlex
            , Css.width (Css.pct 100)
            , Css.maxWidth (Css.px 1380)
            , Css.marginTop exSpacingXxl
            , Css.marginRight Css.auto
            , Css.marginLeft Css.auto
            , Css.flex Css.auto
            , Css.flexGrow (Css.int 0)
            ]
        ]
        [ loadingView
        ]


loadingView : Styled.Html msg
loadingView =
    div [ StyledAttribs.css [ Css.width (Css.pct 100) ] ]
        [ LoadingPlaceholder.view (LoadingPlaceholder.default |> LoadingPlaceholder.size LoadingPlaceholder.Tall |> LoadingPlaceholder.width 20 |> LoadingPlaceholder.marginBottom (LoadingPlaceholder.Custom 40))
        , LoadingPlaceholder.view (LoadingPlaceholder.default |> LoadingPlaceholder.size LoadingPlaceholder.TallXl |> LoadingPlaceholder.width 100)
        ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg, Effect.Effect Effect )
update msg model =
    case msg of
        HeaderMsg headerMsg ->
            let
                ( headerState, headerCmds, headerEffect ) =
                    Header.update model.context.session model.headerState headerMsg
            in
            ( { model | headerState = headerState }, Cmd.map HeaderMsg headerCmds, Effect.map HeaderEffect headerEffect )


subscriptions : Model -> Sub Msg
subscriptions m =
    Sub.map HeaderMsg (Header.subscriptions m.headerState m.context.session)
