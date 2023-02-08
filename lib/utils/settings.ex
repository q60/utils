defmodule Utils.Settings do
  alias Utils.Settings.Setting
  alias Utils.Repo

  import Ecto.Query

  def get(user, key) do
    query =
      from setting in Setting,
        where: setting.user == ^user,
        select: setting

    if setting = Map.get(Repo.one(query), key) do
      setting
    else
      create(user)
      Map.get(Repo.one(query), key)
    end
  end

  def change(user, key, value) do
    query =
      from setting in Setting,
        where: setting.user == ^user,
        select: setting

    if setting = Repo.one(query) do
      setting
      |> Ecto.Changeset.change(%{key => value})
      |> Repo.update()
    else
      create(user, %{key => value})
    end
  end

  def create(user, params \\ %{}) do
    %Setting{}
    |> Setting.changeset(Map.merge(%{user: user, language: "en", theme: "light"}, params))
    |> Repo.insert()
  end
end
