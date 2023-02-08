defmodule UtilsWeb.UserForgotPasswordLive do
  use UtilsWeb, :live_view

  alias Utils.Accounts
  alias Helpers.Cube

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        <%= gettext("forgot your password?") %>
        <:subtitle><%= gettext("we'll send a password reset link to your inbox") %></:subtitle>
      </.header>

      <.simple_form :let={f} id="reset_password_form" for={:user} phx-submit="send_email">
        <.input field={{f, :email}} type="email" placeholder={gettext("email")} required />
        <:actions>
          <.button phx-disable-with={gettext("sending...")} class="w-full">
            <%= gettext("send password reset instructions") %>
          </.button>
        </:actions>
      </.simple_form>
      <p class="text-center mt-4">
        <.link href={~p"/users/register"}><%= gettext("register") %></.link>
        |
        <.link href={~p"/users/log_in"}><%= gettext("log in") %></.link>
      </p>
    </div>
    """
  end

  def mount_default(socket, reply, params \\ []) do
    {reply,
     assign(
       socket,
       Keyword.merge(
         [
           page_title: "forgot password?",
           scramble: Cube.scramble()
         ],
         params
       )
     )}
  end

  def mount(_params, _session, socket) do
    mount_default(socket, :ok)
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      gettext(
        "if your email is in our system, you will receive instructions to reset your password shortly."
      )

    mount_default(
      socket
      |> put_flash(:info, info)
      |> redirect(to: ~p"/"),
      :noreply
    )
  end
end
