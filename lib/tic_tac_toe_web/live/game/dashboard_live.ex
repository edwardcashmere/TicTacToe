defmodule TicTacToeWeb.DashboardLive do
  @moduledoc false

  use TicTacToeWeb, :live_view

  alias TicTacToe
  alias TicTacToe.Games
  alias TicTacToeWeb.Player
  on_mount {TicTacToeWeb.Auth, :user}

  @symbols ["X", "O"]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        mode: nil,
        game_id: nil,
        games: TicTacToe.Games.list_games()
      )

    {:ok, socket}
  end

  def handle_params(%{"game_id" => game_id}, _uri, socket) do
    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "choice",
        %{"choice" => choice},
        %{assigns: %{current_user: current_user}} = socket
      ) do
    case choice do
      "multiplayer" = mode ->
        {:ok, game} =
          TicTacToe.Games.create_game(%{
            mode: mode,
            players: [%Player{name: current_user.email, symbol: Enum.random(["X", "O"])}]
          })

        socket =
          socket
          |> assign(mode: "multiplayer")
          |> push_redirect(to: Routes.game_path(socket, :game, game.id))

        {:noreply, socket}

      "singleplayer" = mode ->
        {:ok, game} =
          TicTacToe.Games.create_game(%{
            mode: mode,
            players: [%Player{name: current_user.email, symbol: Enum.random(@symbols)}]
          })

        socket =
          socket
          |> assign(mode: "singleplayer")
          |> push_redirect(to: Routes.game_path(socket, :game, game.id))

        {:noreply, socket}
    end
  end

  def handle_event(
        "join-game",
        %{"game-id" => game_id},
        %{assigns: %{current_user: current_user}} = socket
      ) do
    game = Games.get_game!(game_id)

    player_symbol = Enum.at(game.players, 0)["symbol"]

    [symbol] = Enum.filter(@symbols, fn symbol -> symbol != player_symbol end)

    {:ok, _} =
      Games.update_game(game, %{
        players: [%Player{name: current_user.email, symbol: symbol} | game.players]
      })

    Phoenix.PubSub.broadcast_from!(
      TicTacToe.PubSub,
      self(),
      "game-" <> game.id,
      {:player_joined, current_user.email}
    )

    {:noreply, socket |> push_redirect(to: Routes.game_path(socket, :game, game.id))}
  end
end
