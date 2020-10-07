module Pages.Example exposing (Model, Msg, init, toContext, update, view)

import Author exposing (Author)
import Components.Button as Button
import Components.ElmLogo as ElmLogo
import Context exposing (Context)
import Css as Css
import Example as Example exposing (Example)
import Header as Header
import Html.Styled as Styled exposing (Attribute, div, h2, li, p, span, text, ul)
import Html.Styled.Attributes as StyledAttribs
import Html.Styled.Extra exposing (viewIf, viewMaybe)
import Http
import Markdown as Markdown
import Package exposing (Package)
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
    , packageName : Package
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
    | Building
    | Built Example.Id
    | BuildError


type Status a
    = StatusIdle
    | Loading
    | LoadingSlowly
    | Loaded a
    | Failed


init : Author -> Package -> Context -> ( Model, Cmd Msg )
init author package context =
    ( { author = author
      , packageName = package
      , examples = Loading
      , descriptionPanel = Closed
      , viewPanel = Idle
      , context = context
      }
      --  fetch examples
    , Example.fetch CompletedLoadExamples
    )


view : Model -> { title : String, content : Styled.Html Msg }
view model =
    let
        descriptionOpen =
            model.descriptionPanel == Open
    in
    { title = "examples"
    , content =
        stageWrapper
            [ sliderLeft model, sliderCenter (not <| descriptionOpen) model.viewPanel, sliderRight model ]
    }


commonSliderStyles : List Css.Style
commonSliderStyles =
    [ Css.position Css.absolute
    , Css.height (Css.pct 100)
    ]


sliderCenter : Bool -> ViewPanel -> Styled.Html msg
sliderCenter center viewPanel =
    div
        [ StyledAttribs.css
            [ Css.width (Css.pct 100)
            , Css.height (Css.pct 100)
            , Css.backgroundColor exColorColt100
            ]
        ]
        [ centerWrapper center [ centerContentShadow center, centerContent viewPanel ] ]


centerWrapper : Bool -> List (Styled.Html msg) -> Styled.Html msg
centerWrapper center content =
    div
        [ centerWrapperStyles center
        ]
        content


centerContent : ViewPanel -> Styled.Html msg
centerContent viewPanel =
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
        [ case viewPanel of
            Building ->
                animatedBuildingView

            _ ->
                text ""
        ]


animatedBuildingView : Styled.Html msg
animatedBuildingView =
    div
        [ StyledAttribs.css <|
            [ Css.top (Css.pct 10) ]
                ++ CommonStyles.absoluteCenterHorizontal
        ]
        [ ElmLogo.view <|
            (ElmLogo.animated ElmLogo.BasicBlink
                |> ElmLogo.color ElmLogo.Official
                |> ElmLogo.size ElmLogo.Large
            )
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



-- UPDATE


type Msg
    = ToggleDescriptionPanel
    | SelectExample Example
    | CompletedLoadExamples (Result Http.Error (List Example))


update : Msg -> Model -> ( Model, Cmd Msg )
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
            ( { model | descriptionPanel = panel }, Cmd.none )

        SelectExample example ->
            let
                ( resolvedExamples, resolvedViewPanel ) =
                    case model.examples of
                        Loaded ( _, examples ) ->
                            ( Loaded ( SelectedExample example, examples ), Building )

                        _ ->
                            ( StatusIdle, Idle )
            in
            ( { model | examples = resolvedExamples, viewPanel = resolvedViewPanel }, Cmd.none )

        CompletedLoadExamples (Ok examples) ->
            let
                resolveExamples =
                    case examples of
                        -- preselect the first example by default
                        head :: _ ->
                            Loaded ( SelectedExample head, examples )

                        [] ->
                            StatusIdle
            in
            ( { model | examples = resolveExamples, viewPanel = Building }, Cmd.none )

        CompletedLoadExamples (Err err) ->
            ( model, Cmd.none )
