module Pages.NotFound exposing (..)

import Browser as Browser exposing (Document)
import Html exposing (Html, div, h1, img, main_, text)
import Html.Attributes exposing (alt, class, id, src, tabindex)


view : Document msg
view =
    { title = "Page Not Found"
    , body =
        [ main_ [ id "content", class "container", tabindex -1 ]
            [ h1 [] [ text "Not Found" ]
            , div [ class "row" ]
                [ img [ alt "sdsdsdsd", src "/assets/images/error.jpg" ] [] ]
            ]
        ]
    }
