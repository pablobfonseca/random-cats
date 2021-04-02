module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, string)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Model
    = Failure
    | Loading
    | Success String


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, getRandomCatGif )



-- UPDATE


type Msg
    = MorePlease
    | GotGif (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MorePlease ->
            ( Loading, getRandomCatGif )

        GotGif result ->
            case result of
                Ok url ->
                    ( Success url, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ node "link"
            [ rel "stylesheet"
            , href "https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/css/materialize.min.css"
            ]
            []
        , nav []
            [ div
                [ class "nav-wrapper light-blue lighten-2" ]
                [ div
                    [ class "brand-logo center" ]
                    [ text "Random Cats" ]
                ]
            ]
        , section
            [ class "container" ]
            [ viewGif model ]
        ]


viewGif : Model -> Html Msg
viewGif model =
    case model of
        Failure ->
            div [ class "center" ]
                [ text "I could not load a random cat for some reason."
                , button
                    [ class "waves-effect waves-light btn"
                    , onClick MorePlease
                    ]
                    [ text "Try Again!" ]
                ]

        Loading ->
            text "Loading..."

        Success url ->
            div
                [ class "row" ]
                [ div
                    [ class "col s12 m7" ]
                    [ div
                        [ class "card" ]
                        [ div
                            [ class "card-image" ]
                            [ img
                                [ src url ]
                                []
                            , span
                                [ class "card-title" ]
                                [ text "Cute!" ]
                            ]
                        , div
                            [ class "card-content" ]
                            [ p
                                []
                                [ text "lorem ipsum" ]
                            ]
                        , div
                            [ class "card-action" ]
                            [ button
                                [ onClick MorePlease
                                , class "waves-effect waves-light btn"
                                ]
                                []
                            ]
                        ]
                    ]
                ]


getRandomCatGif : Cmd Msg
getRandomCatGif =
    Http.get
        { url = "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=cat"
        , expect = Http.expectJson GotGif gifDecoder
        }


gifDecoder : Decoder String
gifDecoder =
    field "data" (field "image_url" string)
