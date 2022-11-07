defmodule TicTacToe.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset
  @type t() :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "games" do
    field :mode, :string
    field :players, {:array, :map}

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:mode, :players])
    |> validate_required([:mode, :players])
  end
end
