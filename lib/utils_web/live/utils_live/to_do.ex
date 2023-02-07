defmodule UtilsWeb.UtilsLive.ToDo do
  use UtilsWeb, :live_view

  alias Utils.Tasks
  alias Utils.Tasks.Task
  alias Helpers.Cube

  attr :task, Task
  attr :changeset, :map
  attr :edit_id, :integer
  attr :id, :integer

  def task_form(assigns) do
    ~H"""
    <%= if @edit_id == @id do %>
      <.form :let={f} for={@changeset} phx-submit="save" phx-click-away="change">
        <.input
          field={{f, :description}}
          type="text"
          value={@task.description}
          class="!text-lg font-['Iosevka_Term_Slab'] rounded-none mx-2 w-[calc(100%-1rem)]"
        />
        <.input field={{f, :id}} value={@task.id} class="hidden" />
        <.input field={{f, :edit_id}} value={@edit_id} class="hidden" />
        <.button
          class="bg-rose-300 hover:bg-rose-400 text-sm font-['Iosevka'] rounded-none my-2 mx-2"
          phx-disable-with="saving..."
        >
          change
        </.button>
      </.form>
    <% else %>
      <span
        phx-click="change"
        phx-value-edit_id={@id}
        class="text-slate-900 peer hover:text-gray-700 mr-2 cursor-pointer"
      >
        <%= @task.description %>
      </span>
      <span class="invisible text-slate-900 peer-hover:visible text-gray-700">
        &hellip;
      </span>
    <% end %>
    """
  end

  def mount_default(socket, reply, params \\ []) do
    tasks = Tasks.list()
    changeset = Task.changeset(%Task{}, %{})

    {reply,
     assign(
       socket,
       Keyword.merge(
         [
           page: "todo list",
           tasks: tasks,
           changeset: changeset,
           scramble: Cube.scramble(),
           edit_id: 0
         ],
         params
       )
     )}
  end

  def mount(_, _, socket) do
    mount_default(socket, :ok)
  end

  def handle_event("delete", %{"id" => id}, socket) do
    {id, _} = Integer.parse(id)
    Tasks.delete(id)
    mount_default(socket, :noreply)
  end

  def handle_event("done", %{"id" => id}, socket) do
    {id, _} = Integer.parse(id)
    Tasks.make_completed(id)
    mount_default(socket, :noreply)
  end

  def handle_event("change", %{"edit_id" => id}, socket) do
    {id, _} = Integer.parse(id)
    mount_default(socket, :noreply, edit_id: id)
  end

  def handle_event("change", %{}, socket) do
    mount_default(socket, :noreply, edit_id: 0)
  end

  def handle_event("save", %{"task" => %{"id" => id, "description" => description}}, socket) do
    {id, _} = Integer.parse(id)
    Tasks.change(id, description)
    mount_default(socket, :noreply, edit_id: 0)
  end

  def handle_event("add", %{"task" => %{"description" => description}}, socket) do
    Tasks.create(%{description: description, completed: false})
    mount_default(socket, :noreply)
  end
end
