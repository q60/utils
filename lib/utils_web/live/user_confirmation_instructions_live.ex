defmodule UtilsWeb.UserConfirmationInstructionsLive do
  use UtilsWeb, :live_view

  alias Utils.Accounts
  alias Helpers.Cube

  def render(assigns) do
    ~H"""
    <.header><%= gettext("resend confirmation instructions") %></.header>

    <.simple_form :let={f} for={:user} id="resend_confirmation_form" phx-submit="send_instructions">
      <.input field={{f, :email}} type="email" label={gettext("email")} required />
      <:actions>
        <.button phx-disable-with={gettext("sending...")}>
          <%= gettext("resend confirmation instructions") %>
        </.button>
      </:actions>
    </.simple_form>

    <p>
      <.link href={~p"/users/register"}><%= gettext("register") %></.link>
      |
      <.link href={~p"/users/log_in"}><%= gettext("log in") %></.link>
    </p>
    """
  end

  def mount_default(socket, reply, params \\ []) do
    {reply,
     assign(
       socket,
       Keyword.merge(
         [
           page_title: "confirmation",
           scramble: Cube.scramble()
         ],
         params
       )
     )}
  end

  def mount(_params, _session, socket) do
    mount_default(socket, :ok)
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    info =
      gettext(
        "if your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."
      )

    mount_default(
      socket
      |> put_flash(:info, info)
      |> redirect(to: ~p"/"),
      :noreply
    )
  end
end
