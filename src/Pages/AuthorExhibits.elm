module Pages.AuthorExhibits exposing (Effect(..), Model, Msg, init, subscriptions, toHeaderMsg, update, view)

import Author exposing (Author)
import Components.ExhibitPane as ExhibitPane
import Components.Paragraph as Paragraph
import Context exposing (Context)
import Css
import Effect
import Exhibit exposing (Exhibit, ExhibitError, fetchAuthorExhibits)
import Header
import Html.Styled as Styled exposing (div, main_, text)
import Html.Styled.Attributes as StyledAttribs
import LoadingPlaceholder.LoadingPlaceholder as LoadingPlaceholder
import Pages.Interstitial.Interstitial as Interstitial
import Styles.Color exposing (exColorColt100)
import Styles.Spacing exposing (exSpacingXxl)


type Msg
    = HeaderMsg Header.Msg
    | CompletedLoadExhibits (Result ExhibitError (List Exhibit))


toHeaderMsg : Header.Msg -> Msg
toHeaderMsg =
    HeaderMsg


type Effect
    = HeaderEffect Header.HeaderEffect


type alias Model =
    { context : Context
    , author : Author
    , exhibits : Status ExhibitError (List Exhibit)
    , headerState : Header.State
    }


init : Author -> Context -> ( Model, Cmd Msg )
init author context =
    ( { context = context
      , author = author
      , exhibits = Loading
      , headerState = Header.initState
      }
    , fetchAuthorExhibits CompletedLoadExhibits author
    )


type Status error success
    = StatusIdle
    | Loading
    | LoadingSlowly
    | Loaded success
    | Failed error


view : Model -> { title : String, content : Styled.Html msg }
view model =
    { title = Author.toString model.author
    , content =
        main_
            [ StyledAttribs.css
                [ Css.backgroundColor exColorColt100
                , Css.position Css.fixed
                , Css.left (Css.px 0)
                , Css.right (Css.px 0)
                , Css.height (Css.pct 100)
                ]
            ]
            [ mainContentWrapper model ]
    }


mainContentWrapper : Model -> Styled.Html msg
mainContentWrapper model =
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
        [ case model.exhibits of
            Loading ->
                loadingView

            Failed e ->
                case e of
                    Exhibit.AuthorNotFound a ->
                        ExhibitPane.view ExhibitPane.default [ Interstitial.view (Interstitial.oops |> Interstitial.content (authorNotFoundView model.author)) ]

                    _ ->
                        text "NOIDEA"

            _ ->
                text "NOIDEA"
        ]


exhibitsContainer : List (Styled.Html msg) -> Styled.Html msg
exhibitsContainer content =
    div [ StyledAttribs.css [ Css.width (Css.pct 100) ] ] content


loadingView : Styled.Html msg
loadingView =
    exhibitsContainer
        [ LoadingPlaceholder.view
            (LoadingPlaceholder.block LoadingPlaceholder.defaultBlock
                |> LoadingPlaceholder.height LoadingPlaceholder.Tall
                |> LoadingPlaceholder.width (LoadingPlaceholder.Pct 20)
                |> LoadingPlaceholder.marginBottom (LoadingPlaceholder.Custom 60)
            )
        , LoadingPlaceholder.view
            (LoadingPlaceholder.block (LoadingPlaceholder.defaultBlock |> LoadingPlaceholder.borderRadius 6)
                |> LoadingPlaceholder.height LoadingPlaceholder.TallXl
                |> LoadingPlaceholder.marginBottom (LoadingPlaceholder.Custom 60)
            )
        , div [ StyledAttribs.css [ Css.property "display" "grid", Css.property "grid-template-columns" "repeat(auto-fill, 300px)", Css.property "grid-gap" "10px", Css.justifyContent Css.spaceBetween ] ]
            [ exhibitContainer
                [ LoadingPlaceholder.view
                    (LoadingPlaceholder.block LoadingPlaceholder.defaultBlock |> LoadingPlaceholder.width (LoadingPlaceholder.Pct 50))
                , LoadingPlaceholder.view
                    (LoadingPlaceholder.block (LoadingPlaceholder.defaultBlock |> LoadingPlaceholder.borderRadius 6) |> LoadingPlaceholder.width (LoadingPlaceholder.Px 300) |> LoadingPlaceholder.height (LoadingPlaceholder.CustomHeight 385))
                ]
            , exhibitContainer
                [ LoadingPlaceholder.view
                    (LoadingPlaceholder.block LoadingPlaceholder.defaultBlock |> LoadingPlaceholder.width (LoadingPlaceholder.Pct 50))
                , LoadingPlaceholder.view
                    (LoadingPlaceholder.block (LoadingPlaceholder.defaultBlock |> LoadingPlaceholder.borderRadius 6) |> LoadingPlaceholder.width (LoadingPlaceholder.Px 300) |> LoadingPlaceholder.height (LoadingPlaceholder.CustomHeight 385))
                ]
            , exhibitContainer
                [ LoadingPlaceholder.view
                    (LoadingPlaceholder.block LoadingPlaceholder.defaultBlock |> LoadingPlaceholder.width (LoadingPlaceholder.Pct 50))
                , LoadingPlaceholder.view
                    (LoadingPlaceholder.block (LoadingPlaceholder.defaultBlock |> LoadingPlaceholder.borderRadius 6) |> LoadingPlaceholder.width (LoadingPlaceholder.Px 300) |> LoadingPlaceholder.height (LoadingPlaceholder.CustomHeight 385))
                ]
            , exhibitContainer
                [ LoadingPlaceholder.view
                    (LoadingPlaceholder.block LoadingPlaceholder.defaultBlock |> LoadingPlaceholder.width (LoadingPlaceholder.Pct 50))
                , LoadingPlaceholder.view
                    (LoadingPlaceholder.block (LoadingPlaceholder.defaultBlock |> LoadingPlaceholder.borderRadius 6) |> LoadingPlaceholder.width (LoadingPlaceholder.Px 300) |> LoadingPlaceholder.height (LoadingPlaceholder.CustomHeight 385))
                ]
            ]
        ]


authorNotFoundView : Author -> List (Styled.Html msg)
authorNotFoundView author =
    [ Paragraph.view (Paragraph.default |> Paragraph.style Paragraph.Intro)
        [ text "We can't seem to find the author "
        , text <| Author.toString author
        , text "."
        ]
    ]


exhibitContainer : List (Styled.Html msg) -> Styled.Html msg
exhibitContainer content =
    div [ StyledAttribs.css [ Css.displayFlex, Css.flexDirection Css.column, Css.alignItems Css.center ] ] content



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

        CompletedLoadExhibits (Ok exhibits) ->
            ( model, Cmd.none, Effect.none )

        CompletedLoadExhibits (Err err) ->
            ( { model | exhibits = Failed err }, Cmd.none, Effect.none )


subscriptions : Model -> Sub Msg
subscriptions m =
    Sub.map HeaderMsg (Header.subscriptions m.headerState m.context.session)
