module Pages.Example exposing (Model, Msg, init, update, view)

import Author exposing (Author)
import Components.Button as Button
import Context exposing (Context)
import Css as Css
import Example as Example exposing (Example)
import Header as Header
import Html.Styled as Styled exposing (Attribute, div, h2, li, p, span, text, ul)
import Html.Styled.Attributes as StyledAttribs
import Html.Styled.Extra exposing (viewMaybe)
import Http
import Package exposing (Package)
import Styles.Color exposing (exColorBorder, exColorColt100, exColorColt200, exColorWhite)
import Styles.Font as Font
import Styles.Grid as Grid
import Styles.Transition as Transition
import Svg.Styled exposing (feGaussianBlur, filter, polygon, rect, svg)
import Svg.Styled.Attributes as SvgStyledAttribs exposing (fill, height, id, in_, points, rx, stdDeviation, viewBox, width, x, y)


type alias Model =
    { author : Author
    , packageName : Package
    , packageExamples : Status (List Example.Example)
    , descriptionPanel : DescriptionPanel
    , selectedExample : SelectedExample
    , context : Context
    }


type DescriptionPanel
    = Open
    | Closed


type SelectedExample
    = Idle
    | Building
    | Built String
    | BuildError


type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed


init : Author -> Package -> Context -> ( Model, Cmd Msg )
init author package context =
    ( { author = author
      , packageName = package
      , packageExamples = Loading
      , descriptionPanel = Closed
      , selectedExample = Idle
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
            [ sliderLeft model, sliderCenter (not <| descriptionOpen), sliderRight descriptionOpen ]
    }


commonSliderStyles : List Css.Style
commonSliderStyles =
    [ Css.position Css.absolute
    , Css.height (Css.pct 100)
    ]


sliderCenter : Bool -> Styled.Html msg
sliderCenter center =
    div
        [ StyledAttribs.css
            [ Css.width (Css.pct 100)
            , Css.height (Css.pct 100)
            , Css.backgroundColor exColorColt100
            ]
        ]
        [ centerWrapper center [ centerContentShadow center, centerContent ] ]


centerWrapper : Bool -> List (Styled.Html msg) -> Styled.Html msg
centerWrapper center content =
    div
        [ centerWrapperStyles center
        ]
        content


centerContent : Styled.Html msg
centerContent =
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
        []


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
            case model.packageExamples of
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


sliderRight : Bool -> Styled.Html Msg
sliderRight descriptionOpen =
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
        [ exampleDescription, sliderToggle descriptionOpen ]


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


exampleList : List Example -> Styled.Html Msg
exampleList examples =
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
                exampleSelector
                examples
            )
        ]


exampleDescription : Styled.Html msg
exampleDescription =
    div []
        [ h2 [ StyledAttribs.css [ Css.fontSize Font.fontSizeH2, Css.marginTop Grid.grid ] ]
            [ text "Example Description" ]
        , p [] [ text "Some text goes here about the component and what it can do." ]
        ]


exampleSelector : Example -> Styled.Html Msg
exampleSelector example =
    li [ StyledAttribs.css [ Css.listStyleType Css.none, Css.marginBottom (Grid.calc Grid.grid Grid.divide 2.5) ] ]
        [ span [ StyledAttribs.css [ Css.display Css.inlineBlock ] ]
            [ Button.view
                (Button.secondary
                    |> Button.onClick SelectExample
                )
                example.name
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


triangle : Styled.Html msg
triangle =
    svg [ height "32", viewBox "0 0 150 300" ] [ polygon [ fill "orange", points "0, 150 150, 0 150,300" ] [] ]



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
    | SelectExample
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

        SelectExample ->
            ( model, Cmd.none )

        CompletedLoadExamples (Ok examples) ->
            ( { model | packageExamples = Loaded examples }, Cmd.none )

        CompletedLoadExamples (Err err) ->
            ( model, Cmd.none )
