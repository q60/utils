defmodule UtilsWeb.UtilsLive.CodeBin do
  use UtilsWeb, :live_view

  alias Utils.Documents
  alias Utils.Documents.Document
  alias Helpers.Cube
  alias Helpers.CodeBin, as: Helpers

  import UtilsWeb.CustomComponents, only: [submit_button: 1, textarea: 1]

  def mount_default(socket, reply, params \\ []) do
    changeset = Document.changeset(%Document{}, %{})

    {reply,
     assign(
       socket,
       Keyword.merge(
         [
           page: "code bin",
           languages: Helpers.language_aliases(),
           changeset: changeset,
           scramble: Cube.scramble()
         ],
         params
       )
     )}
  end

  def mount(_, _, socket) do
    mount_default(socket, :ok, text: nil, filename: nil)
  end

  def handle_event(
        "paste",
        %{"document" => %{"text" => text, "language" => lang}},
        socket
      ) do
    lang_alias = Helpers.get_lang_alias(lang)
    url = ~p"/c/#{Documents.create(%{language: lang_alias, text: text})}"

    {:noreply, push_navigate(socket, to: url)}
  end
end
