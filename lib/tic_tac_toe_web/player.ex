defmodule TicTacToeWeb.Player do
  @moduledoc """
    This player struck is used to track players during the game
  """
  @enforce_keys [:name, :symbol]
  @derive {Jason.Encoder, only: [:name, :symbol, :user_id]}
  defstruct [:name, :symbol, :user_id]

  @type t() :: %__MODULE__{name: String.t(), symbol: String.t(), user_id: number()}
end
