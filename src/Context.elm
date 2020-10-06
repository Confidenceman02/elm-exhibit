module Context exposing (Context, navKey, toContext)

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser


type alias Context =
    { host : String
    , navKey : Nav.Key
    }


toContext : Url -> Nav.Key -> Context
toContext url k =
    { host = url.host
    , navKey = k
    }


navKey : Context -> Nav.Key
navKey context =
    context.navKey
