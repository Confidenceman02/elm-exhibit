module Session exposing (Session)

import Browser.Navigation as Nav


type Session
    = Guest Nav.Key
