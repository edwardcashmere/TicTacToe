defmodule TicTacToe.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TicTacToe.Games` context.
  """

  @doc """
  Generate a game.
  """
  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(%{
        mode: "some mode",
        players: %{}
      })
      |> TicTacToe.Games.create_game()

    game
  end
end
