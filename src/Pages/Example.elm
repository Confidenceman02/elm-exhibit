module Pages.Example exposing (Effect(..), Model, Msg, init, toContext, toHeaderMsg, update, view)

import Author exposing (Author)
import Components.Button as Button
import Components.ElmLogo as ElmLogo
import Components.Heading as Heading
import Components.Link as Link
import Components.Paragraph as Paragraph
import Context exposing (Context)
import Css as Css
import Effect as Effect
import Example as Example exposing (Example)
import Header as Header
import Html.Styled as Styled exposing (Attribute, div, h2, li, p, span, text, ul)
import Html.Styled.Attributes as StyledAttribs
import Html.Styled.Extra exposing (viewIf, viewMaybe)
import Markdown as Markdown
import Package exposing (Package)
import Pages.Errors.Errors as ErrorPage
import Styles.Color exposing (exColorBorder, exColorColt100, exColorColt200, exColorOfficialDarkBlue, exColorWhite)
import Styles.Common as CommonStyles
import Styles.Font as Font
import Styles.Grid as Grid
import Styles.Transition as Transition
import Svg.Styled exposing (feGaussianBlur, filter, path, rect, svg)
import Svg.Styled.Attributes as SvgStyledAttribs exposing (d, fill, height, id, in_, rx, stdDeviation, viewBox, width, x, y)


toContext : Model -> Context
toContext model =
    model.context


type alias Model =
    { author : Author
    , package : Package
    , examples : Status ( SelectedExample, List Example.Example )
    , descriptionPanel : DescriptionPanel
    , viewPanel : ViewPanel
    , context : Context
    }


type SelectedExample
    = SelectedExample Example


type DescriptionPanel
    = Open
    | Closed


type ViewPanel
    = Idle
    | Building Example ViewPanelOptions
    | Built Example
    | BuildError Example.ExampleError


type alias ViewPanelOptions =
    { animationColors : Bool
    }


type Status a
    = StatusIdle
    | Loading
    | LoadingSlowly
    | Loaded a
    | Failed


type Msg
    = ToggleDescriptionPanel
    | SelectExample Example
    | CompletedLoadExamples (Result Example.ExampleError (List Example))
    | CompletedBuildExample (Result Example.ExampleError Example.CompiledExample)
    | HeaderMsg Header.Msg


type Effect
    = HeaderEffect Header.HeaderEffect


toHeaderMsg : Header.Msg -> Msg
toHeaderMsg =
    HeaderMsg


init : Author -> Package -> Context -> ( Model, Cmd Msg )
init author package context =
    ( { author = author
      , package = package
      , examples = Loading
      , descriptionPanel = Closed
      , viewPanel = Idle
      , context = context
      }
    , Example.fetch CompletedLoadExamples author package
    )


view : Model -> { title : String, content : Styled.Html Msg }
view model =
    let
        examplesExist =
            case model.examples of
                Failed ->
                    False

                _ ->
                    True
    in
    { title = "examples"
    , content =
        stageWrapper
            [ sliderLeft model, sliderCenter model, viewIf examplesExist (sliderRight model) ]
    }


commonSliderStyles : List Css.Style
commonSliderStyles =
    [ Css.position Css.absolute
    , Css.height (Css.pct 100)
    ]


sliderCenter : Model -> Styled.Html Msg
sliderCenter model =
    let
        descriptionOpen =
            model.descriptionPanel == Open

        centerSlider =
            not <| descriptionOpen
    in
    div
        [ StyledAttribs.css
            [ Css.width (Css.pct 100)
            , Css.height (Css.pct 100)
            , Css.backgroundColor exColorColt100
            ]
        ]
        [ centerWrapper centerSlider [ centerContentShadow centerSlider, centerContent model ] ]


centerWrapper : Bool -> List (Styled.Html msg) -> Styled.Html msg
centerWrapper center content =
    div
        [ centerWrapperStyles center
        ]
        content


centerContent : Model -> Styled.Html Msg
centerContent model =
    div
        [ StyledAttribs.css
            [ Css.display Css.block
            , Css.position Css.relative
            , Css.width (Css.px centerContentWidth)
            , Css.height (Css.px centerContentHeight)
            , Css.overflow Css.hidden
            , Css.backgroundColor exColorWhite
            , Css.borderRadius (Css.px 12)
            ]
        ]
        [ case model.viewPanel of
            Building example _ ->
                animatedBuildingView example

            BuildError exampleError ->
                exampleErrorToView model.examples exampleError

            _ ->
                text ""
        ]


exampleErrorToView : Status ( SelectedExample, List Example.Example ) -> Example.ExampleError -> Styled.Html msg
exampleErrorToView examples exampleError =
    case exampleError of
        Example.AuthorAndPackageNotFound author package ->
            ErrorPage.view
                (ErrorPage.bummer
                    |> ErrorPage.content (authorAndPackageNotFoundErrorView author package)
                )

        Example.AuthorNotFound author package foundAuthor ->
            ErrorPage.view
                (ErrorPage.weird |> ErrorPage.content (authorNotFoundView author package foundAuthor))

        Example.PackageNotFound author package ->
            ErrorPage.view (ErrorPage.weird |> ErrorPage.content (packageNotFoundView author package))

        Example.KeineAhnung ->
            ErrorPage.view (ErrorPage.ourBad |> ErrorPage.content keineAhnungView)

        _ ->
            text "ExampleBuildFailed"


keineAhnungView : List (Styled.Html msg)
keineAhnungView =
    [ Paragraph.view
        (Paragraph.default
            |> Paragraph.style Paragraph.Intro
        )
        [ text "We aren't exactly sure what happened but we're really sorry!" ]
    ]


packageNotFoundView : Author -> Package -> List (Styled.Html msg)
packageNotFoundView author package =
    [ Paragraph.view (Paragraph.default |> Paragraph.style Paragraph.Intro)
        [ text "We can't seem to find the exhibit "
        , text <| Package.toString package
        , text "."
        , Paragraph.view Paragraph.default [ text <| Author.toString author, text " has some other exhibits you might like to checkout though. " ]
        , Paragraph.view Paragraph.default
            [ text "See them "
            , Link.view
                (Link.default
                    |> Link.href "/"
                )
                (Link.stringBody "here")
            , text "."
            ]
        ]
    ]


authorNotFoundView : Author -> Package -> Example.FoundAuthor -> List (Styled.Html msg)
authorNotFoundView author package foundAuthor =
    let
        resolvedExhibitHref =
            "/" ++ String.join "/" [ "example", Author.toString foundAuthor, Package.toString package ]
    in
    [ Paragraph.view (Paragraph.default |> Paragraph.style Paragraph.Intro)
        [ text "We can't seem to find the exhibitionist "
        , text <| Author.toString author
        , text "."
        , Paragraph.view Paragraph.default
            [ text "Looks like the "
            , text <| Package.toString package
            , text " exhibit belongs to "
            , text (Author.toString foundAuthor)
            , text " though."
            ]
        , Paragraph.view Paragraph.default [ text "Is that who you meant?" ]
        , Paragraph.view Paragraph.default
            [ text "Check out the exhibit "
            , Link.view
                (Link.default
                    |> Link.href resolvedExhibitHref
                )
                (Link.stringBody "here")
            ]
        ]
    ]


authorAndPackageNotFoundErrorView : Author -> Package -> List (Styled.Html msg)
authorAndPackageNotFoundErrorView author package =
    [ Paragraph.view (Paragraph.default |> Paragraph.style Paragraph.Intro)
        [ text "We can’t seem to find the exhibitionist "
        , Paragraph.view
            (Paragraph.default
                |> Paragraph.style Paragraph.Intro
                |> Paragraph.inline True
            )
            [ text <| Author.toString author ]
        , text " or the "
        , Paragraph.view
            (Paragraph.default
                |> Paragraph.style Paragraph.Intro
                |> Paragraph.inline True
            )
            [ text <| Package.toString package ]
        , text " exhibit."
        ]
    , Paragraph.view Paragraph.default
        [ text "You can search for other exhibits "
        , Link.view Link.default (Link.stringBody "here")
        , text " or check out some of our personal favourites below."
        ]
    ]


animatedBuildingView : Example -> Styled.Html Msg
animatedBuildingView example =
    div []
        [ div
            [ StyledAttribs.css <|
                [ Css.top (Css.pct 10) ]
                    ++ CommonStyles.absoluteCenterHorizontal
            ]
            [ ElmLogo.view <|
                (ElmLogo.animated ElmLogo.BasicShapeBlink
                    |> ElmLogo.color (ElmLogo.CustomColor exColorColt200)
                    |> ElmLogo.size ElmLogo.Large
                )
            ]
        , div
            [ StyledAttribs.css ([ Css.top (Css.pct 30) ] ++ CommonStyles.absoluteCenterHorizontal) ]
            [ div [ StyledAttribs.css [ Css.displayFlex, Css.alignItems Css.center, Css.flexDirection Css.column ] ]
                [ div
                    [ StyledAttribs.css [ Css.minWidth (Css.px centerContentWidth), Css.displayFlex, Css.justifyContent Css.center ] ]
                    [ span [] [ Heading.view Heading.h4 ("Building example " ++ example.name) ] ]
                ]
            ]
        ]


centerContentShadow : Bool -> Styled.Html msg
centerContentShadow center =
    svg
        [ width "510"
        , height "691"
        , viewBox "0 0 510 691"
        , centerShadowStyles center
        ]
        [ filter [ id "shadowBlur" ] [ feGaussianBlur [ in_ "sourceGraphics", stdDeviation "7" ] [] ]
        , rect
            [ x "14.855576"
            , y "16.587036"
            , rx "12"
            , height (String.fromFloat centerContentHeight)
            , width (String.fromFloat centerContentWidth)
            , fill exColorColt200.value
            , SvgStyledAttribs.filter "url(#shadowBlur)"
            ]
            []
        ]


sliderLeft : Model -> Styled.Html Msg
sliderLeft model =
    let
        maybeExamples =
            case model.examples of
                Loaded examples ->
                    Just examples

                _ ->
                    Nothing
    in
    div
        [ StyledAttribs.css
            ([ Css.width (Css.pct sliderLeftWidth)
             , Css.left (Css.pct 0)
             ]
                ++ commonSliderStyles
            )
        ]
        [ viewMaybe exampleList maybeExamples ]


sliderRight : Model -> Styled.Html Msg
sliderRight model =
    let
        descriptionOpen =
            model.descriptionPanel == Open
    in
    let
        resolveTransform =
            if descriptionOpen then
                0

            else
                100

        resolveOpacity =
            if descriptionOpen then
                1

            else
                0
    in
    div
        [ StyledAttribs.css
            ([ Css.width (Css.pct sliderRightWidth)
             , Css.right (Css.pct 0)
             , Css.top (Css.px 0)
             , Css.backgroundColor exColorWhite
             , Css.paddingLeft Grid.halfGrid
             , Css.paddingRight Grid.halfGrid
             , Css.boxSizing Css.borderBox
             , Css.before
                ([ Css.property "content" "''"
                 , Css.paddingRight Grid.grid
                 , Css.width <|
                    Css.calc
                        (Css.pct 100)
                        Css.minus
                        Grid.grid
                 , Css.height (Css.pct 100)
                 , Css.boxShadow4 (Css.px -7) (Css.px 10) (Css.px 14) exColorBorder
                 , Css.position Css.absolute
                 , Css.right (Css.pct 0)
                 ]
                    ++ Transition.opacity resolveOpacity
                )
             ]
                ++ commonSliderStyles
                ++ Transition.transform (Css.translateX <| Css.pct resolveTransform)
            )
        ]
        [ exampleDescription model, sliderToggle descriptionOpen ]


stageWrapper : List (Styled.Html msg) -> Styled.Html msg
stageWrapper content =
    div
        [ StyledAttribs.css
            [ Css.top (Css.px 0)
            , Css.bottom (Css.px 0)
            , Css.position Css.fixed
            , Css.width (Css.pct 100)
            , Css.marginTop (Css.px (Header.navHeight + Header.navBottomBorder))
            ]
        ]
        content


exampleList : ( SelectedExample, List Example ) -> Styled.Html Msg
exampleList ( selectedExample, examples ) =
    let
        paddingCalc =
            (Css.calc Grid.halfGrid Css.minus (Css.px 2)).value
    in
    div [ StyledAttribs.css [ Css.textAlign Css.right, Css.margin4 (Grid.calc Grid.grid Grid.divide 1.25) (Css.px 0) (Css.px 0) (Css.px 0) ] ]
        [ h2
            [ StyledAttribs.css
                [ Css.fontSize Font.fontSizeH2
                , Css.marginTop Grid.grid
                , Css.property "padding-right" paddingCalc
                ]
            ]
            [ text "Examples" ]
        , ul []
            (List.map
                (exampleSelector selectedExample)
                examples
            )
        ]


exampleDescription : Model -> Styled.Html msg
exampleDescription model =
    let
        resolveDescription =
            case model.examples of
                Loaded ( SelectedExample selectedExample, _ ) ->
                    selectedExample.description

                _ ->
                    ""
    in
    Styled.fromUnstyled <| Markdown.toHtml [] resolveDescription


exampleSelector : SelectedExample -> Example -> Styled.Html Msg
exampleSelector (SelectedExample selectedExample) example =
    li [ StyledAttribs.css [ Css.listStyleType Css.none, Css.marginBottom (Grid.calc Grid.grid Grid.divide 2.5) ] ]
        [ span [ StyledAttribs.css [ Css.display Css.inlineBlock, Css.position Css.relative ] ]
            [ Button.view
                (Button.secondary
                    |> Button.onClick (SelectExample example)
                )
                example.name
            , viewIf (selectedExample.id == example.id) selectedTriangle
            ]
        ]


sliderToggle : Bool -> Styled.Html Msg
sliderToggle open =
    let
        orientation =
            if open then
                Button.Open

            else
                Button.Closed
    in
    Button.view
        (Button.icon (Button.Triangle orientation)
            |> Button.onClick ToggleDescriptionPanel
        )
        "open slider"


selectedTriangle : Styled.Html msg
selectedTriangle =
    svg
        [ height "8"
        , viewBox "0 0 8 8"
        , SvgStyledAttribs.css
            [ Css.transform <| Css.translate2 (Css.pct 0) (Css.pct -50)
            , Css.top (Css.pct 50)
            , Css.position Css.absolute
            , Css.marginLeft Grid.halfGrid
            ]
        ]
        [ path [ d "M0.402038 4.01184L7.15204 0.114727L7.15204 7.90895L0.402038 4.01184Z", fill exColorOfficialDarkBlue.value ] [] ]



-- STYLES


sliderLeftWidth : Float
sliderLeftWidth =
    25


sliderRightWidth : Float
sliderRightWidth =
    32


centerContentWidth : Float
centerContentWidth =
    460


centerContentHeight : Float
centerContentHeight =
    590


centerWrapperStyles : Bool -> Attribute msg
centerWrapperStyles center =
    let
        resolveLeft =
            if center then
                50

            else
                46
    in
    StyledAttribs.css
        ([ Css.position Css.absolute
         , Css.transform (Css.translate2 (Css.pct -50) (Css.pct 0))
         , Css.marginTop (Grid.calc Grid.grid Grid.multiply 1.5)
         ]
            ++ Transition.left (Css.pct resolveLeft)
        )


centerShadowStyles : Bool -> Attribute msg
centerShadowStyles center =
    let
        resolveLeft =
            if center then
                -3

            else
                -4
    in
    SvgStyledAttribs.css
        ([ Css.position Css.absolute
         , Css.top (Css.pct -1.5)
         ]
            ++ Transition.left (Css.pct resolveLeft)
        )



-- DEFAULTS


defaultViewPanelOptions : ViewPanelOptions
defaultViewPanelOptions =
    { animationColors = True
    }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg, Effect.Effect Effect )
update msg model =
    case msg of
        ToggleDescriptionPanel ->
            let
                panel =
                    case model.descriptionPanel of
                        Open ->
                            Closed

                        _ ->
                            Open
            in
            ( { model | descriptionPanel = panel }, Cmd.none, Effect.none )

        SelectExample example ->
            let
                ( resolvedExamples, resolvedViewPanel ) =
                    case model.examples of
                        Loaded ( _, examples ) ->
                            ( Loaded ( SelectedExample example, examples ), Building example defaultViewPanelOptions )

                        _ ->
                            ( StatusIdle, Idle )
            in
            ( { model | examples = resolvedExamples, viewPanel = resolvedViewPanel }, Cmd.none, Effect.none )

        CompletedLoadExamples (Ok examples) ->
            let
                ( resolvedExamples, resolvedViewPanel, exampleCmd ) =
                    case examples of
                        -- preselect the first example by default
                        head :: _ ->
                            ( Loaded ( SelectedExample head, examples )
                            , Building head defaultViewPanelOptions
                              -- send build example request
                            , Example.build CompletedBuildExample model.author model.package head
                            )

                        [] ->
                            ( StatusIdle, Idle, Cmd.none )
            in
            ( { model | examples = resolvedExamples, viewPanel = resolvedViewPanel }, exampleCmd, Effect.none )

        CompletedLoadExamples (Err err) ->
            ( { model | examples = Failed, viewPanel = BuildError err }, Cmd.none, Effect.none )

        CompletedBuildExample (Ok compiledExample) ->
            ( model, Cmd.none, Effect.none )

        CompletedBuildExample (Err err) ->
            ( model, Cmd.none, Effect.none )

        HeaderMsg headerMsg ->
            let
                headerEffect =
                    Header.update headerMsg
            in
            ( model, Cmd.none, Effect.map HeaderEffect headerEffect )
