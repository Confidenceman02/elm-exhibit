module Session exposing (Session, init)


type Session
    = LoggedIn
    | Guest
    | LoggingIn
    | CheckingForAuth


init : Session
init =
    CheckingForAuth
