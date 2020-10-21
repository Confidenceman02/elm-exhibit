module Session exposing (Session, SessionError, SessionSuccess, init, isIdle, refresh, toSession)

import Api.Api as Api
import Api.Endpoint as Endpoint
import Http exposing (Response)
import Json.Decode as Decode exposing (Decoder)
import Viewer exposing (Cred, Viewer)


type Session
    = LoggedIn Viewer
    | Guest
    | Idle
    | LoggingIn
    | RestoringSession


init : Session
init =
    Idle


toSession : Result SessionError SessionSuccess -> Session
toSession result =
    case result of
        Ok (SessionRefreshed cred) ->
            LoggedIn (Viewer.init cred)

        Ok (SessionGranted cred) ->
            LoggedIn (Viewer.init cred)

        Err RefreshFailed ->
            Guest

        _ ->
            Guest


isIdle : Session -> Bool
isIdle sesh =
    case sesh of
        Idle ->
            True

        _ ->
            False


type SessionError
    = RefreshFailed
    | KeineAhnung


type SessionSuccess
    = SessionRefreshed Cred
    | SessionGranted Cred


mapTagToSessionSuccess : String -> Decoder SessionSuccess
mapTagToSessionSuccess tag =
    case tag of
        "SessionRefreshed" ->
            Decode.map SessionRefreshed Viewer.credDecoder

        "SessionGranted" ->
            Decode.map SessionGranted Viewer.credDecoder

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

        Http.GoodStatus_ _ body ->
            case Decode.decodeString decoder body of
                Ok decodedBody ->
                    Ok decodedBody

                Err err ->
                    Err KeineAhnung

        _ ->
            Err KeineAhnung


refresh : (Result SessionError SessionSuccess -> msg) -> Cmd msg
refresh toMsg =
    Api.get
        (Endpoint.lambdaUrl [ "session-refresh" ] [])
        toMsg
        (decodeResponseString
            successBodyDecoder
        )
