defmodule Utils.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :short, :string
      add :language, :string
      add :text, :binary

      timestamps()
    end
  end
end
