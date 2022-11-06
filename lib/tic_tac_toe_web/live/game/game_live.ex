defmodule TicTacToeWeb.GameLive do
@moduledoc false

use TicTacToeWeb, :live_view


on_mount {TicTacToeWeb.Auth, :user}

@impl true
def mount(_params, _session, socket) do


  socket =
    socket
    |> assign(
      mode: nil,

              )

  {:ok, socket}
end

def handle_params(params, _uri, socket) do

  {:noreply, socket}
end

@impl true
def handle_event("choice", %{"choice" => choice}, socket) do
  case choice do
    "multiplayer" ->
      socket =
        socket
        |> assign(mode: "multiplayer")
        |> push_patch(to: Routes.game_path(socket, :board, 1))

      {:noreply, socket}

    "singleplayer" ->
      socket =
        socket
        |> assign(mode: "singleplayer")
        |> push_patch(to: Routes.game_path(socket,:board, 1))

      {:noreply, socket}
  end
end

end
