module Components.Indicator exposing (Orientation(..), view)

import Css
import Html.Styled as Styled
import Styles.Color exposing (exColorOfficialDarkBlue)
import Styles.Transition as Transition
import Svg.Styled exposing (path, svg)
import Svg.Styled.Attributes as SvgAttribs exposing (d, fill, height, viewBox)


type Orientation
    = RightFacing
    | LeftFacing
    | UpFacing
    | DownFacing


view : Orientation -> Styled.Html msg
view orientation =
    let
        resolveOrientation =
            case orientation of
                LeftFacing ->
                    0

                UpFacing ->
                    90

                RightFacing ->
                    180

                DownFacing ->
                    270
    in
    svg
        [ height "8"
        , viewBox "0 0 8 8"
        , SvgAttribs.css
            ([ Css.fill Css.currentColor ] ++ Transition.transform (Css.rotate <| Css.deg resolveOrientation))
        ]
        [ path [ d "M0.402038 4.01184L7.15204 0.114727L7.15204 7.90895L0.402038 4.01184Z" ] [] ]
