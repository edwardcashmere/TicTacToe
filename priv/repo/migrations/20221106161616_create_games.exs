defmodule TicTacToe.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :mode, :string
      add :players, {:array, :map}

      timestamps()
    end
  end
end
