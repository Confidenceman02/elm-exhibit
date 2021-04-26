module Pages.AuthorExhibits exposing (Effect(..), Model, Msg, init, subscriptions, toHeaderMsg, update, view)

import Author exposing (Author)
import AuthorExhibits as AuthorExhibits exposing (AuthorExhibit, AuthorExhibitsError)
import Components.AddLogo as AddLogo
import Components.Button as Button
import Components.ExhibitPane as ExhibitPane
import Components.Heading as Heading
import Components.Paragraph as Paragraph
import Context exposing (Context)
import Css
import Effect
import Header
import Html.Styled as Styled exposing (div, main_, text)
import Html.Styled.Attributes as StyledAttribs
import LoadingPlaceholder.LoadingPlaceholder as LoadingPlaceholder
import Pages.Interstitial.Interstitial as Interstitial
import Styles.Color exposing (exColorBorder, exColorColt100, exColorColt200)
import Styles.Spacing exposing (exSpacingLg, exSpacingXxl)


type Msg
    = HeaderMsg Header.Msg
    | CompletedLoadExhibits (Result AuthorExhibitsError (List AuthorExhibit))


toHeaderMsg : Header.Msg -> Msg
toHeaderMsg =
    HeaderMsg


type Effect
    = HeaderEffect Header.HeaderEffect



-- CONSTANTS


exhibitButtonWidth : Float
exhibitButtonWidth =
    exhibitButtonHeight / ExhibitPane.heightRatio * ExhibitPane.widthRatio


exhibitButtonHeight : Float
exhibitButtonHeight =
    400


type alias Model =
    { context : Context
    , author : Author
    , exhibits : Status AuthorExhibitsError (List AuthorExhibit)
    , headerState : Header.State
    }


init : Author -> Context -> ( Model, Cmd Msg )
init author context =
    ( { context = context
      , author = author
      , exhibits = Loading
      , headerState = Header.initState
      }
    , AuthorExhibits.fetch CompletedLoadExhibits author
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
                    AuthorExhibits.AuthorNotFound a ->
                        errorContainer
                            [ ExhibitPane.view ExhibitPane.default
                                [ Interstitial.view
                                    (Interstitial.bummer
                                        |> Interstitial.content (authorNotFoundView model.author)
                                    )
                                ]
                            ]

                    _ ->
                        errorContainer
                            [ ExhibitPane.view ExhibitPane.default
                                [ Interstitial.view
                                    (Interstitial.ourBad
                                        |> Interstitial.content keineAhnungErrorView
                                    )
                                ]
                            ]

            Loaded e ->
                div [ StyledAttribs.css [ Css.margin2 (Css.px 0) Css.auto, Css.displayFlex, Css.flexDirection Css.column ] ]
                    [ div [ StyledAttribs.css [ Css.width (Css.pct 60), Css.margin2 (Css.px 0) Css.auto, Css.textAlign Css.center, Css.marginBottom exSpacingLg ] ]
                        [ Heading.view
                            (Heading.h4
                                |> Heading.overrides [ StyledAttribs.css [ Css.fontWeight (Css.int 400) ] ]
                                |> Heading.inline True
                                |> Heading.overrides []
                            )
                            "Create an exhibit to start sharing your elm package examples."
                        ]
                    , div [ StyledAttribs.css [ Css.margin2 (Css.px 0) Css.auto ] ]
                        [ Button.view
                            (Button.wrapper
                                [ div [ StyledAttribs.css [ Css.width (Css.px exhibitButtonWidth), Css.height (Css.px exhibitButtonHeight) ] ]
                                    [ Heading.view (Heading.h3 |> Heading.overrides [ StyledAttribs.css [ Css.margin (Css.px 0) ] ]) "Create an exhibit"
                                    , AddLogo.view
                                    ]
                                ]
                                |> Button.padding False
                                |> Button.backgroundColor exColorBorder
                                |> Button.hoverColor exColorColt200
                            )
                            "Create an exhibit"
                        ]
                    ]

            _ ->
                text "NOIDEA"
        ]


errorContainer : List (Styled.Html msg) -> Styled.Html msg
errorContainer content =
    div
        [ StyledAttribs.css
            [ Css.position Css.absolute
            , Css.left (Css.pct 50)
            , Css.marginLeft (Css.px -(ExhibitPane.defaultContentWidth / 2))
            ]
        ]
        content


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


keineAhnungErrorView : List (Styled.Html msg)
keineAhnungErrorView =
    [ Paragraph.view (Paragraph.default |> Paragraph.style Paragraph.Intro)
        [ text "We aren't exactly sure what happened but we're really sorry!."
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
            ( { model | exhibits = Loaded exhibits }, Cmd.none, Effect.none )

        CompletedLoadExhibits (Err err) ->
            ( { model | exhibits = Failed err }, Cmd.none, Effect.none )


subscriptions : Model -> Sub Msg
subscriptions m =
    Sub.map HeaderMsg (Header.subscriptions m.headerState m.context.session)
