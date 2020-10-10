module Components.ElmLogo exposing (Animation(..), Color(..), Size(..), animated, color, size, static, view)

import Css exposing (Style)
import Css.Animations as CssAnimation
import Html.Styled as Styled
import Styles.Color exposing (exColorOfficialDarkBlue, exColorOfficialGreen, exColorOfficialLightBlue, exColorOfficialYellow)
import Svg.Styled as SvgStyled exposing (Svg, polygon, svg)
import Svg.Styled.Attributes as SvgAttributes exposing (fill, height, points, viewBox)


type Config
    = Config Configuration


type State
    = State InternalState


type alias InternalState =
    { keyframesForShapes : LogoShapeCompatible (List Style)
    }


type alias Configuration =
    { variant : Variant
    , size : Size
    , color : Color
    , state : State
    }


type Variant
    = Static
    | Animated Animation


type Size
    = Medium
    | Large
    | Custom Float


type Color
    = Current
    | Official
    | CustomColor Css.Color


type Animation
    = BasicShapeBlink


defaults : Configuration
defaults =
    { variant = Static
    , size = Medium
    , color = Current
    , state = init
    }


size : Size -> Config -> Config
size s (Config config) =
    Config { config | size = s }



--VARIANTS


static : Config
static =
    Config { defaults | variant = Static }


animated : Animation -> Config
animated animationType =
    Config { defaults | variant = Animated animationType }



-- MODIFIERS


color : Color -> Config -> Config
color c (Config config) =
    Config { config | color = c }



-- VIEW


view : Config -> Styled.Html msg
view ((Config config) as con) =
    svg [ height <| String.fromFloat (sizeToFloat config.size), viewBox "0 0 600 600" ] (logoShapes con)


logoShapes : Config -> List (Svg msg)
logoShapes (Config config) =
    let
        (State state) =
            config.state

        resolveAnimationF f =
            case config.variant of
                Animated _ ->
                    Just f

                _ ->
                    Nothing
    in
    [ buildShape (resolveAnimationF .logoShape01) .logoShape01 .logoShape01 config.color state
    , buildShape (resolveAnimationF .logoShape02) .logoShape02 .logoShape02 config.color state
    , buildShape (resolveAnimationF .logoShape03) .logoShape03 .logoShape03 config.color state
    , buildShape (resolveAnimationF .logoShape04) .logoShape04 .logoShape04 config.color state
    , buildShape (resolveAnimationF .logoShape05) .logoShape05 .logoShape05 config.color state
    , buildShape (resolveAnimationF .logoShape06) .logoShape06 .logoShape06 config.color state
    , buildShape (resolveAnimationF .logoShape07) .logoShape07 .logoShape07 config.color state
    ]


buildShape :
    Maybe (LogoShapeCompatible (List Style) -> List Style)
    -> (LogoShapeCompatible (SvgStyled.Attribute msg) -> SvgStyled.Attribute msg)
    -> (LogoShapeCompatible Css.Color -> Css.Color)
    -> Color
    -> InternalState
    -> Svg msg
buildShape maybeKeyFrameF pointF colorF clr state =
    let
        resolveColor =
            case clr of
                Current ->
                    "currentColor"

                Official ->
                    colorF logoShapeColors |> .value

                CustomColor cc ->
                    cc.value

        resolveKeyFrames =
            case maybeKeyFrameF of
                Just keyFrameF ->
                    keyFrameF state.keyframesForShapes

                _ ->
                    []
    in
    polygon [ SvgAttributes.css resolveKeyFrames, fill resolveColor, pointF logoShapePoint ] []


logoShapeKeyFrame : LogoShapeCompatible (List Style)
logoShapeKeyFrame =
    { logoShape01 =
        [ Css.opacity <| Css.num 0
        , Css.animationName <|
            CssAnimation.keyframes
                [ ( 0, [ CssAnimation.opacity (Css.num 0) ] ), ( 7, [ CssAnimation.opacity (Css.num 1) ] ), ( 14, [ CssAnimation.opacity (Css.num 0) ] ), ( 100, [ CssAnimation.opacity (Css.num 0) ] ) ]
        , Css.animationDuration (Css.sec logoAnimationDuration)
        , Css.property "animation-iteration-count" "infinite"
        ]
    , logoShape02 =
        [ Css.opacity <| Css.num 0
        , Css.animationName <|
            CssAnimation.keyframes
                [ ( 0, [ CssAnimation.opacity (Css.num 0) ] ), ( 7, [ CssAnimation.opacity (Css.num 1) ] ), ( 14, [ CssAnimation.opacity (Css.num 0) ] ), ( 100, [ CssAnimation.opacity (Css.num 0) ] ) ]
        , Css.animationDuration (Css.sec logoAnimationDuration)
        , Css.property "animation-iteration-count" "infinite"
        , Css.animationDelay (Css.sec logoAnimationDelay)
        ]
    , logoShape03 =
        [ Css.opacity <| Css.num 0
        , Css.animationName <|
            CssAnimation.keyframes
                [ ( 0, [ CssAnimation.opacity (Css.num 0) ] ), ( 7, [ CssAnimation.opacity (Css.num 1) ] ), ( 14, [ CssAnimation.opacity (Css.num 0) ] ), ( 100, [ CssAnimation.opacity (Css.num 0) ] ) ]
        , Css.animationDuration (Css.sec logoAnimationDuration)
        , Css.property "animation-iteration-count" "infinite"
        , Css.animationDelay (Css.sec (logoAnimationDelay * 2))
        ]
    , logoShape04 =
        [ Css.opacity <| Css.num 0
        , Css.animationName <|
            CssAnimation.keyframes
                [ ( 0, [ CssAnimation.opacity (Css.num 0) ] ), ( 7, [ CssAnimation.opacity (Css.num 1) ] ), ( 14, [ CssAnimation.opacity (Css.num 0) ] ), ( 100, [ CssAnimation.opacity (Css.num 0) ] ) ]
        , Css.animationDuration (Css.sec logoAnimationDuration)
        , Css.property "animation-iteration-count" "infinite"
        , Css.animationDelay (Css.sec (logoAnimationDelay * 3))
        ]
    , logoShape05 =
        [ Css.opacity <| Css.num 0
        , Css.animationName <|
            CssAnimation.keyframes
                [ ( 0, [ CssAnimation.opacity (Css.num 0) ] ), ( 7, [ CssAnimation.opacity (Css.num 1) ] ), ( 14, [ CssAnimation.opacity (Css.num 0) ] ), ( 100, [ CssAnimation.opacity (Css.num 0) ] ) ]
        , Css.animationDuration (Css.sec logoAnimationDuration)
        , Css.property "animation-iteration-count" "infinite"
        , Css.animationDelay (Css.sec (logoAnimationDelay * 4))
        ]
    , logoShape06 =
        [ Css.opacity <| Css.num 0
        , Css.animationName <|
            CssAnimation.keyframes
                [ ( 0, [ CssAnimation.opacity (Css.num 0) ] ), ( 7, [ CssAnimation.opacity (Css.num 1) ] ), ( 14, [ CssAnimation.opacity (Css.num 0) ] ), ( 100, [ CssAnimation.opacity (Css.num 0) ] ) ]
        , Css.animationDuration (Css.sec logoAnimationDuration)
        , Css.property "animation-iteration-count" "infinite"
        , Css.animationDelay (Css.sec (logoAnimationDelay * 5))
        ]
    , logoShape07 =
        [ Css.opacity <| Css.num 0
        , Css.animationName <|
            CssAnimation.keyframes
                [ ( 0, [ CssAnimation.opacity (Css.num 0) ] ), ( 7, [ CssAnimation.opacity (Css.num 1) ] ), ( 14, [ CssAnimation.opacity (Css.num 0) ] ), ( 100, [ CssAnimation.opacity (Css.num 0) ] ) ]
        , Css.animationDuration (Css.sec logoAnimationDuration)
        , Css.property "animation-iteration-count" "infinite"
        , Css.animationDelay (Css.sec (logoAnimationDelay * 6))
        ]
    }


logoShapeColors : LogoShapeCompatible Css.Color
logoShapeColors =
    { logoShape01 = exColorOfficialDarkBlue
    , logoShape02 = exColorOfficialLightBlue
    , logoShape03 = exColorOfficialLightBlue
    , logoShape04 = exColorOfficialGreen
    , logoShape05 = exColorOfficialYellow
    , logoShape06 = exColorOfficialGreen
    , logoShape07 = exColorOfficialYellow
    }


logoShapePoint : LogoShapeCompatible (SvgStyled.Attribute msg)
logoShapePoint =
    { logoShape01 = points "0, 20 280, 300 0,580"
    , logoShape02 = points "20,600 300,320 580,600"
    , logoShape03 = points "320,0 600,0 600,280"
    , logoShape04 = points "20,0 280,0 402,122 142,122"
    , logoShape05 = points "170,150 430,150 300,280"
    , logoShape06 = points "320,300 450,170 580,300 450,430"
    , logoShape07 = points "470,450 600,320 600,580"
    }


type alias LogoShapeCompatible compatible =
    { logoShape01 : compatible
    , logoShape02 : compatible
    , logoShape03 : compatible
    , logoShape04 : compatible
    , logoShape05 : compatible
    , logoShape06 : compatible
    , logoShape07 : compatible
    }



-- CONSTANTS


logoAnimationDuration : Float
logoAnimationDuration =
    2.5


logoAnimationDelay : Float
logoAnimationDelay =
    logoAnimationDuration / 7



-- HELPERS


sizeToFloat : Size -> Float
sizeToFloat s =
    case s of
        Medium ->
            32

        Large ->
            70

        Custom cs ->
            cs



-- STATE


initialState : InternalState
initialState =
    { keyframesForShapes = logoShapeKeyFrame
    }


init : State
init =
    State initialState
