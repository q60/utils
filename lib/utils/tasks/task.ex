defmodule Utils.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :user, :string
    field :description, :string
    field :completed, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:user, :description, :completed])
  end
end
