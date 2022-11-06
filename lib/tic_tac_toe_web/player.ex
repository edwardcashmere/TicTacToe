defmodule TicTacToeWeb.Player do
@moduledoc """
  This player struck is used to track players during the game
"""
@enforce_keys [:name, :symbol]
defstruct [:name, :symbol, :victories, :losses, :user_id]

@type t() ::  %__MODULE__{name: String.t(), symbol: String.t(), victories: number(), losses: number(), user_id: number()}

end
