module Context exposing (Context, toContext)

import Url exposing (Url)
import Url.Parser


type alias Context =
    { host : String
    }


toContext : Url -> Context
toContext url =
    { host = url.host
    }
