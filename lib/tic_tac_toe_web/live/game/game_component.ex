defmodule TicTacToeWeb.GameComponent do
@moduledoc false

use TicTacToeWeb, :live_component

alias TicTacToeWeb.Player

# on_mount {TicTacToeWeb.Auth, :user}

@symbols ["X", "O"]

@impl true
def update(assigns = %{mode: "multiplayer", current_user: current_user}, socket) do
  socket =
    socket
    |> assign(assigns)
    |> assign(
      board: Enum.map(1..9, fn index -> %{position: index, value: nil} end),
      winner: nil,
      player_1: %Player{user_id: current_user.id,name: "Player " <> "X", symbol: @symbols[Enum.random(0..1)] },
      active_payer: :player_1,
      player_2: nil,
      game_start: false
              )

  {:ok, socket}
end
def update(assigns = %{mode: "singleplayer"}, socket) do
  socket =
    socket
    |> assign(assigns)
    |> assign(
      board: Enum.map(1..9, fn index -> %{position: index, value: nil} end),
      winner: nil,
      player_1: %Player{name: "Player " <> "X", symbol: @symbols[Enum.random(0..1)] },
      active_payer: nil
              )

  {:ok, socket}
end
def update(_assigns, socket) do
  socket =
    socket
    |> push_patch(to: Routes.game_path(socket, :game, 1))

  {:ok, socket}
end

def handle_event("mark", %{"position" => position}, socket) do
  # IO.inspect(position, label: "position")
  {:noreply, socket}
end

defp maybe_add_svg_icon(value) do
  if value do
    case value do
      "X" ->
        IO.puts("x svg icon")
      "O" ->
        IO.puts("o svg icon")
    end
  end
end

end
