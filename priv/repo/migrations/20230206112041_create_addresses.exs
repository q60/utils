defmodule Utils.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :short, :string
      add :target, :string

      timestamps()
    end
  end
end
