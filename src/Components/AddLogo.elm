module Components.AddLogo exposing (..)

import Html.Styled as Styled
import Styles.Color exposing (exColorOfficialGreen)
import Svg.Styled exposing (path, rect, svg)
import Svg.Styled.Attributes exposing (d, fill, height, rx, viewBox, width)


view : Styled.Html msg
view =
    svg
        [ width "40"
        , viewBox "0 0 20 22"
        , fill "none"
        ]
        [ rect
            [ width "20"
            , height "21.0526"
            , rx "4"
            , fill exColorOfficialGreen.value
            ]
            []
        , path [ fill "white", d "M16.1578 11.2632H10.6842V17.1579C10.6842 17.5646 10.3777 17.8947 9.99994 17.8947C9.62234 17.8947 9.31577 17.5646 9.31577 17.1579V11.2632H3.84206C3.46446 11.2632 3.1579 10.933 3.1579 10.5264C3.1579 10.1196 3.46446 9.78945 3.84206 9.78945H9.31577V3.89483C9.31577 3.48804 9.62234 3.1579 9.99994 3.1579C10.3777 3.1579 10.6842 3.48804 10.6842 3.89483V9.78945H16.1578C16.5355 9.78945 16.8421 10.1196 16.8421 10.5264C16.8421 10.933 16.5355 11.2632 16.1578 11.2632V11.2632Z" ] []
        ]
