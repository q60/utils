defmodule UtilsWeb.CustomComponents do
  use Phoenix.Component
  alias UtilsWeb.CoreComponents, as: Core

  slot :inner_block, required: true
  attr :link, :any

  def big_button(assigns) do
    ~H"""
    <.link navigate={@link}>
      <Core.button class="bg-gray-900 hover:bg-gray-800 text-4xl font-['Gilbert'] rounded-md py-6 px-4 hover:scale-110 hover:font-['Gilbert_Color'] hover:bg-transparent ease-out duration-300">
        <%= render_slot(@inner_block) %>
      </Core.button>
    </.link>
    """
  end

  slot :inner_block, required: true
  attr :disable_with, :string, default: nil

  def submit_button(assigns) do
    ~H"""
    <Core.button
      class="bg-rose-300 hover:bg-rose-400 text-sm font-['Iosevka'] rounded-none my-4"
      phx-disable-with={@disable_with}
    >
      <%= render_slot(@inner_block) %>
    </Core.button>
    """
  end

  attr :field, :any
  attr :value, :string
  attr :placeholder, :string

  def textarea(assigns) do
    ~H"""
    <%= {form, name} = @field

    Phoenix.HTML.Form.textarea(form, name,
      class:
        "!text-lg font-['IBM_Plex_Mono'] bg-purple-50 rounded-none !my-4 w-full min-h-[400px] resize-none",
      value: @value,
      placeholder: @placeholder
    ) %>
    """
  end
end
