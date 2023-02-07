defmodule Utils.Tasks do
  alias Utils.Tasks.Task
  alias Utils.Repo

  import Ecto.Query

  def get(id), do: Repo.get(Task, id)

  def list() do
    query = order_by(Task, desc: :id)

    Repo.all(query)
    |> Enum.sort_by(&((&1.completed && 1) || 0))
  end

  def make_completed(id) do
    get(id)
    |> Ecto.Changeset.change(completed: true)
    |> Repo.update()
  end

  def change(id, description) do
    get(id)
    |> Ecto.Changeset.change(description: description)
    |> Repo.update()
  end

  def delete(id) do
    get(id)
    |> Repo.delete()
  end

  def create(params) do
    %Task{}
    |> Task.changeset(params)
    |> Repo.insert()
  end
end
