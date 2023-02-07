defmodule Utils.Addresses.Address do
  use Ecto.Schema
  import Ecto.Changeset

  schema "addresses" do
    field :short, :string
    field :target, :string

    timestamps()
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, [:short, :target])
  end
end
