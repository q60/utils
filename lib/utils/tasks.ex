defmodule Utils.Tasks do
  alias Utils.Tasks.Task
  alias Utils.Repo

  import Ecto.Query

  def get(id, user) do
    query =
      from task in Task,
        where: task.user == ^user and task.id == ^id,
        select: task

    Repo.one(query)
  end

  def list(user) do
    query =
      from task in Task,
        where: task.user == ^user,
        select: task

    query
    |> order_by(desc: :id)
    |> Repo.all()
    |> Enum.sort_by(&((&1.completed && 1) || 0))
  end

  def make_completed(id, user) do
    get(id, user)
    |> Ecto.Changeset.change(completed: true)
    |> Repo.update()
  end

  def change(id, user, description) do
    get(id, user)
    |> Ecto.Changeset.change(description: description)
    |> Repo.update()
  end

  def delete(id, user) do
    get(id, user)
    |> Repo.delete()
  end

  def create(params) do
    %Task{}
    |> Task.changeset(params)
    |> Repo.insert()
  end
end
