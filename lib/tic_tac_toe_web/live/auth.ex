defmodule TicTacToeWeb.Auth do
@moduledoc """
this module is called everytime a new liveview is called it ensures we have user in the session
"""
  import Phoenix.LiveView
  import Phoenix.Component

  alias TicTacToe.Accounts

  def on_mount(:user, _params ,%{"user_token" => user_token}, socket) do
    socket =
      assign_new(socket, :current_user, fn -> Accounts.get_user_by_session_token(user_token) end)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/users/log_in")}
    end
  end
end
