defmodule UtilsWeb.PageHTML do
  use UtilsWeb, :html

  def code(assigns) do
    ~H"""
    <link
      rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/styles/default.min.css"
    />
    <div class="px-8 py-8">
      <h1 class="pl-2 text-lg font-['Iosevka_Term_Slab'] pb-4"><%= @lang_name %></h1>
      <hr class="w-[10%]" />
      <pre class="pt-4 min-w-[50%] max-w-[100%] inline-block"><code id="code" phx-hook="Highlight" class={"font-['IBM_Plex_Mono'] !bg-transparent rounded-md language-#{@lang_alias}"}><%= @text %></code></pre>
    </div>
    """
  end
end
