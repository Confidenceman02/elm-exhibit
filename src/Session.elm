module Session exposing
    ( ExchangeableCode
    , Session
    , SessionError
    , SessionSuccess
    , fromResult
    , init
    , isGuest
    , isIdle
    , isLoggingIn
    , isRefreshing
    , isSignedIn
    , login
    , refresh
    )

import Api.Api as Api
import Api.Endpoint as Endpoint
import Browser.Navigation as Nav
import Http exposing (Response)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Viewer exposing (Cred, Viewer)


type Session
    = SignedIn Viewer
    | Guest
    | Idle
    | LoggingIn
    | Refreshing


type ExchangeableCode
    = ExchangeableCode String


init : Session
init =
    Idle


fromResult : Result SessionError SessionSuccess -> ( Cmd msg, Session )
fromResult result =
    case result of
        Ok (SessionRefreshed cred) ->
            ( Cmd.none, SignedIn (Viewer.init cred) )

        Ok (SessionGranted cred) ->
            ( Cmd.none, SignedIn (Viewer.init cred) )

        Ok (Redirecting meta) ->
            ( Nav.load meta.location, LoggingIn )

        _ ->
            ( Cmd.none, Guest )


type SessionError
    = RefreshFailed
    | KeineAhnung


type SessionSuccess
    = SessionRefreshed Cred
    | Redirecting RedirectBody
    | SessionGranted Cred


type alias RedirectBody =
    { location : String
    }


redirectingDecoder : Decoder RedirectBody
redirectingDecoder =
    Decode.succeed RedirectBody
        |> required "location" Decode.string


mapTagToSessionSuccess : String -> Decoder SessionSuccess
mapTagToSessionSuccess tag =
    case tag of
        "SessionRefreshed" ->
            Decode.map SessionRefreshed Viewer.credDecoder

        "SessionGranted" ->
            Decode.map SessionGranted Viewer.credDecoder

        "Redirecting" ->
            Decode.map Redirecting redirectingDecoder

        _ ->
            Decode.fail "Could not decode session success tag"


successBodyDecoder : Decoder SessionSuccess
successBodyDecoder =
    Decode.field "tag" Decode.string |> Decode.andThen mapTagToSessionSuccess


mapTagToSessionError : String -> Decoder SessionError
mapTagToSessionError tag =
    case tag of
        "RefreshFailed" ->
            Decode.succeed RefreshFailed

        _ ->
            Decode.succeed KeineAhnung


errorBodyDecoder : Decoder SessionError
errorBodyDecoder =
    Decode.field "tag" Decode.string
        |> Decode.andThen mapTagToSessionError


decodeResponseString : Decoder a -> Response String -> Result SessionError a
decodeResponseString decoder response =
    case response of
        Http.BadStatus_ _ body ->
            case Decode.decodeString errorBodyDecoder body of
                Ok errorBody ->
                    Err errorBody

                Err _ ->
                    Err KeineAhnung

        Http.GoodStatus_ metadata body ->
            case Decode.decodeString decoder body of
                Ok decodedBody ->
                    Ok decodedBody

                Err err ->
                    Err KeineAhnung

        _ ->
            Err KeineAhnung


refresh : (Result SessionError SessionSuccess -> msg) -> ( Cmd msg, Session )
refresh toMsg =
    ( Api.get
        (Endpoint.lambdaUrl [ "session-refresh" ] [])
        toMsg
        (decodeResponseString
            successBodyDecoder
        )
    , Refreshing
    )


{-|

    When logging in there is a chance user will be redirected to authorize github app.
    We lose the state as it is thus far but the origin page will be returned to on
    successful auth.

-}
login : (Result SessionError SessionSuccess -> msg) -> ( Cmd msg, Session )
login toMsg =
    ( Api.get
        (Endpoint.lambdaUrl [ "session-grant" ] [])
        toMsg
        (decodeResponseString successBodyDecoder)
    , LoggingIn
    )



-- HELPERS


isIdle : Session -> Bool
isIdle sesh =
    case sesh of
        Idle ->
            True

        _ ->
            False


isRefreshing : Session -> Bool
isRefreshing sesh =
    case sesh of
        Refreshing ->
            True

        _ ->
            False


isSignedIn : Session -> Bool
isSignedIn sesh =
    case sesh of
        SignedIn _ ->
            True

        _ ->
            False


isGuest : Session -> Bool
isGuest sesh =
    case sesh of
        Guest ->
            True

        _ ->
            False


isLoggingIn : Session -> Bool
isLoggingIn sesh =
    case sesh of
        LoggingIn ->
            True

        _ ->
            False
