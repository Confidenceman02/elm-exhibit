module Context exposing (Context, navKey, toContext)

import Browser.Navigation as Nav
import Session exposing (Session)
import Url exposing (Url)


type alias Context =
    { host : String
    , navKey : Nav.Key
    , session : Session
    }


toContext : Url -> Nav.Key -> Session -> Context
toContext url k session =
    { host = url.host
    , navKey = k
    , session = session
    }


navKey : Context -> Nav.Key
navKey context =
    context.navKey
