defmodule UtilsWeb.UtilsLive.Index do
  use UtilsWeb, :live_view

  alias Helpers.Cube
  import UtilsWeb.CustomComponents, only: [big_button: 1]

  def mount_default(socket, reply, params \\ []) do
    {reply,
     assign(
       socket,
       Keyword.merge(
         [page: "home", scramble: Cube.scramble()],
         params
       )
     )}
  end

  def mount(_, _, socket) do
    mount_default(socket, :ok)
  end
end
