defmodule TicTacToeWeb.GameLive do
  use TicTacToeWeb, :live_view

  alias TicTacToe.Games
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
      |> assign(player: filter_players(game.players, socket.assigns.current_user))
      |> assign(winner?: false)
      |> assign(draw?: false)
      |> assign(players: Enum.count(game.players))
      |> assign(game_start: false || Enum.count(game.players) > 1)
      |> assign(
        active_player?: maybe_set_active_player(game.players, socket.assigns.current_user)
      )

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "mark",
        %{"position" => _selected_position, "value" => _value} = _params,
        %{assigns: %{active_player?: true}} = socket
      ) do
    {:noreply, socket |> put_flash(:info, "position taken try again")}
  end

  def handle_event(
        "mark",
        %{"position" => selected_position},
        %{assigns: %{board: board, player: player, game: game, active_player?: true}} = socket
      ) do
    new_board =
      Enum.map(board, fn %{position: cur_pos, value: value} = pos ->
        if String.to_integer(selected_position) == cur_pos && !value do
          Map.put(pos, :value, player["symbol"])
        else
          pos
        end
      end)

    case check_winner(new_board) do
      true ->
        # tell the other player the game has winner
        Games.broadcast!(self(), "game-" <> game.id, {:winner, player})
        # disable board reduce opacity
        # set winner to true
        # possibly color the winning move
        socket =
          socket
          |> assign(:winner?, true)
          |> assign(board: new_board)

        {:noreply, socket |> put_flash(:info, "You Won the game")}

      _ ->
        Games.broadcast!(
          self(),
          "game-" <> game.id,
          {:board_updated, {selected_position, player["symbol"]}}
        )

        if check_draw(new_board) do
          socket =
            socket
            |> assign(board: new_board)
            |> assign(draw?: true)

          Games.broadcast!(self(), "game-" <> game.id, {:draw})

          {:noreply, socket |> put_flash(:info, "Its a draw!!!")}
        else
          socket =
            socket
            |> assign(board: new_board)
            |> assign(active_player?: false)

          {:noreply, socket}
        end
    end
  end

  def handle_event(
        "mark",
        %{"position" => _selected_position},
        %{assigns: %{board: _board, player: _player, game: _game, active_player?: false}} = socket
      ) do
    {:noreply, socket |> put_flash(:info, "it is not your turn")}
  end

  def handle_event("new_game", _params, %{assigns: %{game: game}} = socket) do
    Games.broadcast!(self(), "game-" <> game.id, :new_game)

    socket =
      socket
      |> assign(board: Enum.map(0..8, fn index -> %{position: index, value: nil} end))
      |> assign(winner?: false)
      |> assign(draw?: false)
      |> assign(active_player?: true)

    {:noreply, socket}
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

  def handle_info({:winner, player}, socket) do
    socket =
      socket
      |> assign(:winner?, true)

    {:noreply, socket |> put_flash(:info, "#{player["name"]} won the game")}
  end

  def handle_info({:draw}, socket) do
    socket =
      socket
      |> assign(:draw?, true)

    {:noreply, socket |> put_flash(:info, "Its a draw!!!")}
  end

  def handle_info(:new_game, socket) do
    socket =
      socket
      |> assign(board: Enum.map(0..8, fn index -> %{position: index, value: nil} end))
      |> assign(winner?: false)
      |> assign(draw?: false)

    {:noreply, socket}
  end

  defp check_draw(board) do
    Enum.all?(board, fn %{value: value} -> value != nil end)
  end

  defp check_winner(board) do
    winning_moves = [
      {0, 1, 2},
      {3, 4, 5},
      {6, 7, 8},
      {0, 3, 6},
      {1, 4, 7},
      {2, 5, 8},
      {0, 4, 8},
      {2, 4, 6}
    ]

    Enum.any?(winning_moves, fn {pos1, pos2, pos3} ->
      Enum.at(board, pos1).value != nil and
        Enum.at(board, pos1).value == Enum.at(board, pos2).value and
        Enum.at(board, pos2).value == Enum.at(board, pos3).value
    end)
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

  defp maybe_set_active_player(players, current_user) do
    if players > 1 do
      Enum.at(players, 1)["user_id"] == current_user.id
    else
      false
    end
  end

  defp filter_players_for_name(players, current_user) do
    if length(players) > 1 do
      [player] = Enum.filter(players, fn player -> player["name"] != current_user.email end)
      player["name"]
    else
      ""
    end
  end

  defp filter_players(players, current_user) do
    [player] = Enum.filter(players, fn player -> player["name"] == current_user.email end)
    player
  end
end
