defmodule Utils.Repo.Migrations.CreateSetting do
  use Ecto.Migration

  def change do
    create table(:setting) do
      add :user, :string
      add :language, :string
      add :theme, :string

      timestamps()
    end
  end
end
