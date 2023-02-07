defmodule Utils.Addresses do
  alias Utils.Addresses.Address
  alias Utils.Repo

  import Ecto.Query

  @alphabet 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

  defp random_string(existing) do
    <<i1::unsigned-integer-32, i2::unsigned-integer-32, i3::unsigned-integer-32>> =
      :crypto.strong_rand_bytes(12)

    :rand.seed(:exsp, {i1, i2, i3})

    short = for _ <- 1..5, into: "", do: <<Enum.random(@alphabet)>>
    if short in existing, do: random_string(existing), else: short
  end

  def get(short) do
    query =
      from url in Address,
        where: url.short == ^short,
        select: url.target

    Repo.one(query)
  end

  def create(%{target: target}) do
    query = from url in Address, select: url.short
    existing = Repo.all(query)

    short = random_string(existing)

    %Address{}
    |> Address.changeset(%{target: target, short: short})
    |> Repo.insert()

    short
  end
end
