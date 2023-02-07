defmodule Utils.Documents.Document do
  use Ecto.Schema
  import Ecto.Changeset

  schema "documents" do
    field :short, :string
    field :language, :string
    field :text, :binary

    timestamps()
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:short, :language, :text])
  end
end
