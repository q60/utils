defmodule UtilsWeb.UtilsLive.Shortener do
  use UtilsWeb, :live_view

  alias Utils.Addresses
  alias Utils.Addresses.Address
  alias Helpers.Cube

  import UtilsWeb.CustomComponents, only: [submit_button: 1]

  def mount_default(socket, reply, params \\ []) do
    changeset = Address.changeset(%Address{}, %{})

    {reply,
     assign(
       socket,
       Keyword.merge(
         [page: "url shortener", changeset: changeset, scramble: Cube.scramble()],
         params
       )
     )}
  end

  def mount(_, _, socket) do
    mount_default(socket, :ok, shortened: "")
  end

  def handle_event("shorten", %{"address" => %{"target" => target}}, socket) do
    shortened = Addresses.create(%{target: target})

    socket
    |> assign(:shortened, "#{UtilsWeb.Endpoint.url()}/s/#{shortened}")
    |> mount_default(:noreply)
  end
end
