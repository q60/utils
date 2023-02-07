defmodule Utils.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :description, :string
      add :completed, :boolean, default: false

      timestamps()
    end
  end
end
