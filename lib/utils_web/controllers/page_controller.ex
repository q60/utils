defmodule UtilsWeb.PageController do
  use UtilsWeb, :controller

  alias Helpers.CodeBin, as: Helpers

  def shortener_path(conn, %{"short" => short}) do
    target = Utils.Addresses.get(short)
    uri = if URI.parse(target).scheme, do: target, else: "http://#{target}"

    redirect(conn, external: uri)
  end

  def bin_path(conn, %{"short" => short}) do
    doc = Utils.Documents.get(short)

    put_layout(conn, false)
    |> render(:code,
      lang_alias: doc.language,
      lang_name: Helpers.get_lang_name(doc.language),
      text: doc.text |> :erlang.binary_to_term()
    )
  end

  def bin_path_raw(conn, %{"short" => short}) do
    doc = Utils.Documents.get(short)

    text(conn, doc.text |> :erlang.binary_to_term())
  end
end
