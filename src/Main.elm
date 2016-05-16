module Main exposing(..)

import Html exposing (..)
import Html.Attributes exposing(..)
import Html.App as Html exposing(map)

import Task
import Debug

import Components.Expenses as Expenses exposing (getExpenses)
import Components.BudgetButtonList exposing (getBudgets)
import Components.Login exposing (User)
import Ports exposing(userData)

-- MODEL
type alias Model = {
  data: Expenses.Model,
  user: User
}

initialModel : (Model, Cmd Msg)
initialModel =
  let
    data = Expenses.initialModel
    user = User "" "" False ""
  in
    (Model data user, Cmd.none)

initialLoadEffects : User -> Cmd Msg
initialLoadEffects user =
  if user.authenticated
    then Cmd.batch [ loadExpensesEffect user, loadBudgetsEffect user ]
    else Cmd.none


loadExpensesEffect : User -> Cmd Msg
loadExpensesEffect user =
  getExpenses user |> Cmd.map List


loadBudgetsEffect : User -> Cmd Msg
loadBudgetsEffect user =
  getBudgets user |> Cmd.map Expenses.BudgetList |> Cmd.map List


-- UPDATE
type Msg
  = List Expenses.Msg
  | Login User


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    _ = Debug.log "Update function called" model
  in
    case msg of
      List listAction ->
        let
          (listData, fx) = Expenses.update model.user listAction model.data
        in
          ({ model | data = listData }, Cmd.map List fx)

      Login user ->
        let
          _ = Debug.log "Something" user
        in
          ({ model | user = user }, initialLoadEffects user)


-- VIEW
view : Model -> Html Msg
view model =
  div [ class "container"] [
    div [ class "clear col-12 mt1" ] [
      text ("Welcome " ++ model.user.email)
    ],
    div [ class "clear mt1" ] [
      map List (Expenses.view model.data)
    ]
  ]

-- WIRE STUFF UP
main : Program Never
main =
  Html.program {
      init = initialModel,
      update = update,
      view = view,
      subscriptions = subscriptions
    }


subscriptions model =
  userData Login
