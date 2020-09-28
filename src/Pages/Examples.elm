module Pages.Examples exposing (Model, Msg, init, update, view)

import Author exposing (Author)
import Components.Button as Button
import Css as Css
import Header as Header
import Html.Styled as Styled exposing (Attribute, div, h2, li, p, span, text, ul)
import Html.Styled.Attributes as StyledAttribs
import Package exposing (Package)
import Styles.Color exposing (exColorColt100, exColorColt200, exColorWhite)
import Styles.Font as Font
import Styles.Grid as Grid
import Styles.Transition as Transition
import Svg.Styled exposing (feGaussianBlur, filter, polygon, rect, svg)
import Svg.Styled.Attributes as SvgStyledAttribs exposing (fill, height, id, in_, points, rx, stdDeviation, viewBox, width, x, y)


type alias Model =
    { author : Author
    , package : Package
    , repo : Status Repo
    , descriptionPanel : DescriptionPanel
    , selectedExample : SelectedExample
    }


type DescriptionPanel
    = Open
    | Closed


type alias Repo =
    { avatar : String
    , examples : List Example
    }


type alias Example =
    { name : String
    , description : String
    }


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


init : Author -> Package -> Model
init author package =
    { author = author
    , package = package
    , repo = Loading
    , descriptionPanel = Open
    , selectedExample = Idle
    }


view : Model -> { title : String, content : Styled.Html Msg }
view model =
    let
        descriptionOpen =
            model.descriptionPanel == Open
    in
    { title = "examples"
    , content =
        stageWrapper
            [ sliderLeft, sliderCenter (not <| descriptionOpen), sliderRight descriptionOpen ]
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
        [ width "761"
        , height "691"
        , viewBox "0 0 761 691"
        , centerShadowStyles center
        ]
        [ filter [ id "shadowBlur" ] [ feGaussianBlur [ in_ "sourceGraphics", stdDeviation "7" ] [] ]
        , rect
            [ x "14.855576"
            , y "8.587036"
            , rx "12"
            , height (String.fromFloat centerContentHeight)
            , width (String.fromFloat centerContentWidth)
            , fill exColorColt200.value
            , SvgStyledAttribs.filter "url(#shadowBlur)"
            ]
            []
        ]


sliderLeft : Styled.Html Msg
sliderLeft =
    div
        [ StyledAttribs.css
            ([ Css.width (Css.pct sliderLeftWidth)
             , Css.left (Css.pct 0)
             ]
                ++ commonSliderStyles
            )
        ]
        [ exampleList ]


sliderRight : Bool -> Styled.Html Msg
sliderRight descriptionOpen =
    let
        resolveTransform =
            if descriptionOpen then
                0

            else
                100
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
            [ Css.top (Css.px Header.navHeight)
            , Css.bottom (Css.px 0)
            , Css.position Css.fixed
            , Css.width (Css.pct 100)
            ]
        ]
        content


exampleList : Styled.Html Msg
exampleList =
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
            [ exampleSelector "exampleSelector 1"
            , exampleSelector "exampleSelector 2"
            , exampleSelector "exampleSelector 3"
            , exampleSelector "exampleSelector 4"
            , exampleSelector "exampleSelector 5"
            ]
        ]


exampleDescription : Styled.Html msg
exampleDescription =
    div []
        [ h2 [ StyledAttribs.css [ Css.fontSize Font.fontSizeH2, Css.marginTop Grid.grid ] ]
            [ text "Example Description" ]
        , p [] [ text "Some text goes here about the component and what it can do." ]
        ]


exampleSelector : String -> Styled.Html Msg
exampleSelector name =
    li [ StyledAttribs.css [ Css.listStyleType Css.none, Css.marginBottom (Grid.calc Grid.grid Grid.divide 2.5) ] ]
        [ span [ StyledAttribs.css [ Css.display Css.inlineBlock ] ]
            [ Button.view
                (Button.secondary
                    |> Button.onClick SelectExample
                )
                name
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
         , Css.top (Css.pct 0)
         ]
            ++ Transition.left (Css.pct resolveLeft)
        )



-- UPDATE


type Msg
    = ToggleDescriptionPanel
    | SelectExample


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
