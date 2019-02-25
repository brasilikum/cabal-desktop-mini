port module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Input as Input
import Html exposing (Html)


type Model
    = AddingChat ChatIdentifier
    | LoadingChat
    | LoadingFailing String
    | Chatting ChatIdentifier (List Channel)


type ChatIdentifier
    = ChatIdentifier String


type MyError
    = MyError String


type alias Channel =
    { name : String }


unwrap : ChatIdentifier -> String
unwrap chatIdentifier =
    case chatIdentifier of
        ChatIdentifier id ->
            id


initialModel : flags -> ( Model, Cmd Msg )
initialModel _ =
    ( AddingChat (ChatIdentifier "cabal://14bc77d788fdaf07b89b28e9d276e47f2e44011f4adb981921056e1b3b40e99e"), Cmd.none )


type Msg
    = ChatIdentifierChanged String
    | ChatRequested
    | ChatReceived ChatIdentifier
    | ChannelAdded { chatID : String, name : String }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        res =
            case ( msg, model ) of
                ( ChatIdentifierChanged identifier, AddingChat _ ) ->
                    ( AddingChat (ChatIdentifier identifier), Cmd.none )

                ( ChatRequested, AddingChat id ) ->
                    ( LoadingChat, startChat (unwrap id) )

                ( ChatReceived id, LoadingChat ) ->
                    ( Chatting id [], Cmd.none )

                ( ChannelAdded addition, Chatting id channels ) ->
                    ( Chatting id (channels ++ [ { name = addition.name } ]), Cmd.none )

                ( _, _ ) ->
                    Debug.log "unexpected" ( model, Cmd.none )

        debug =
            Debug.log "update" ( msg, model )
    in
    res


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        AddingChat _ ->
            Sub.none

        LoadingChat ->
            chatStarted (\chat -> ChatReceived (ChatIdentifier chat))

        LoadingFailing _ ->
            Sub.none

        Chatting _ _ ->
            channelAdded ChannelAdded


view : Model -> Html Msg
view model =
    let
        vi =
            case model of
                AddingChat chatIdentifier ->
                    column [ centerX, centerY ]
                        [ text "Welcome to Cabal"
                        , Input.text []
                            { onChange = ChatIdentifierChanged
                            , text = unwrap chatIdentifier
                            , placeholder = Nothing
                            , label = Input.labelAbove [] (text "Please enter a chat identifier")
                            }
                        , Input.button [ centerX ] { onPress = Just ChatRequested, label = text "Enter" }
                        ]

                LoadingChat ->
                    column [ centerX, centerY ]
                        [ text "Chat is loading" ]

                LoadingFailing err ->
                    column [ centerX, centerY ]
                        [ text err ]

                Chatting id channels ->
                    column [ centerX, centerY ]
                        [ text "Chat loaded"
                        , unwrap id |> String.left 14 |> text
                        , column [] (viewChannels channels)
                        ]
    in
    Element.layout [] vi


viewChannels : List Channel -> List (Element Msg)
viewChannels channels =
    case List.isEmpty channels of
        True ->
            [ text "Loading Channels" ]

        False ->
            List.map (\channel -> text channel.name) channels


main : Program () Model Msg
main =
    Browser.element
        { init = initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


port startChat : String -> Cmd msg


port chatStarted : (String -> msg) -> Sub msg


port channelAdded : ({ chatID : String, name : String } -> msg) -> Sub msg
