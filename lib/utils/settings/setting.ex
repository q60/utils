defmodule Utils.Settings.Setting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "setting" do
    field :language, :string
    field :theme, :string
    field :user, :string

    timestamps()
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:user, :language, :theme])
  end
end
