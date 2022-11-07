defmodule TicTacToeWeb.GameLive do
  use TicTacToeWeb, :live_view

  alias TicTacToe.Games
  import TicTacToeWeb.Symbols
  on_mount {TicTacToeWeb.Auth, :user}

  @impl true
  def mount(params, _session, socket) do
    game_id = params["game_id"]

    if connected?(socket) do
      Phoenix.PubSub.subscribe(TicTacToe.PubSub, "game-" <> game_id)
    end

    game = Games.get_game!(game_id)

    socket =
      socket
      |> assign(game: game)
      |> assign(board: Enum.map(0..8, fn index -> %{position: index, value: nil} end))
      |> assign(player: Enum.at(game.players, 0))
      |> assign(winner: nil)
      |> assign(players: Enum.count(game.players))
      |> assign(game_start: false || Enum.count(game.players) > 1)
      |> assign(active_player?: false)

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "mark",
        %{"position" => selected_position},
        %{assigns: %{board: board, player: player, game: game, active_player?: true}} = socket
      ) do
    new_board =
      Enum.map(board, fn %{position: cur_pos} = pos ->
        if String.to_integer(selected_position) == cur_pos do
          Map.put(pos, :value, player["symbol"])
        else
          pos
        end
      end)

    Phoenix.PubSub.broadcast_from!(
      TicTacToe.PubSub,
      self(),
      "game-" <> game.id,
      {:board_updated, {selected_position, player["symbol"]}}
    )

    socket =
      socket
      |> assign(board: new_board)
      |> assign(active_player?: false)

    {:noreply, socket}
  end

  def handle_event(
        "mark",
        %{"position" => _selected_position},
        %{assigns: %{board: _board, player: _player, game: _game, active_player?: false}} = socket
      ) do
    {:noreply, socket |> put_flash(:info, "it is not your turn")}
  end

  @impl true
  def handle_info(
        {:board_updated, {selected_position, value}},
        %{assigns: %{board: board}} = socket
      ) do
    new_board =
      Enum.map(board, fn %{position: cur_pos} = pos ->
        if String.to_integer(selected_position) == cur_pos do
          Map.put(pos, :value, value)
        else
          pos
        end
      end)

    socket =
      socket
      |> assign(board: new_board)
      |> assign(active_player?: true)

    {:noreply, socket}
  end

  def handle_info(
        {:player_joined, player_email},
        %{assigns: %{game: game}} = socket
      ) do
    game = Games.get_game!(game.id)

    socket =
      socket
      |> assign(:game, game)
      |> assign(:game_start, true)
      |> assign(:active_player?, true)

    {:noreply, socket |> put_flash(:info, "player #{player_email} joined the game")}
  end

  defp maybe_add_svg_icon(value) do
    case value do
      "X" ->
        "X"

      "O" ->
        "O"

      _ ->
        ""
    end
  end

  defp filter_players(players, current_user) do
    if length(players) > 1 do
      [player] = Enum.filter(players, fn player -> player["name"] != current_user.email end)
      player["name"]
    else
      ""
    end
  end
end
