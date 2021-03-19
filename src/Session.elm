module Session exposing
    ( Session(..)
    , SessionError
    , SessionId
    , SessionSuccess
    , callBack
    , fromResult
    , getViewer
    , hasFailed
    , init
    , isGuest
    , isIdle
    , isLoggedIn
    , isLoggingIn
    , isRefreshing
    , loggingIn
    , login
    , refresh
    , toSessionId
    )

import Api.Api as Api
import Api.Endpoint as Endpoint
import Browser.Navigation as Nav
import GithubAuth
import Http exposing (Response)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Viewer exposing (Cred, Viewer)


type Session
    = LoggedIn Viewer
    | Guest
    | Idle
    | LoggingIn
    | Refreshing
    | Failed


type SessionId
    = SessionId String


init : Session
init =
    Idle


loggingIn : Session
loggingIn =
    LoggingIn


fromResult : Result SessionError SessionSuccess -> ( Cmd msg, Session )
fromResult result =
    case result of
        Ok (SessionRefreshed cred) ->
            ( Cmd.none, LoggedIn (Viewer.init cred) )

        Ok (SessionGranted cred) ->
            ( Cmd.none, LoggedIn (Viewer.init cred) )

        Ok (Redirecting meta) ->
            ( Nav.load meta.location, LoggingIn )

        Err LoginFailed ->
            ( Cmd.none, Failed )

        _ ->
            ( Cmd.none, Guest )


toSessionId : String -> SessionId
toSessionId id =
    SessionId id


type SessionError
    = RefreshFailed
    | LoginFailed
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
            Decode.map SessionRefreshed (Decode.field "session" Viewer.credDecoder)

        "SessionGranted" ->
            Decode.map SessionGranted (Decode.field "session" Viewer.credDecoder)

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

        "LoginFailed" ->
            Decode.succeed LoginFailed

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

                Err _ ->
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


{-|

    After auth redirect we use the session callback endpoint to exchange the code
    for an access token.

    This endpoint will also do other stuff for us like set the cookie header for
    subsequent requests.

-}
callBack : (Result SessionError SessionSuccess -> msg) -> GithubAuth.CallBackParams -> ( Cmd msg, Session )
callBack toMsg callBackParams =
    ( Api.get
        (Endpoint.lambdaUrl [ "session-auth-callback" ] (GithubAuth.callBackParamsToUrlParams callBackParams))
        toMsg
        (decodeResponseString
            successBodyDecoder
        )
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


isLoggedIn : Session -> Bool
isLoggedIn sesh =
    case sesh of
        LoggedIn _ ->
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


hasFailed : Session -> Bool
hasFailed sesh =
    case sesh of
        Failed ->
            True

        _ ->
            False


getViewer : Session -> Maybe Viewer
getViewer sesh =
    case sesh of
        LoggedIn viewer ->
            Just viewer

        _ ->
            Nothing
