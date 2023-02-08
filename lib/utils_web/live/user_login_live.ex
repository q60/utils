defmodule UtilsWeb.UserLoginLive do
  use UtilsWeb, :live_view

  alias Helpers.Cube

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        <%= gettext("sign in to account") %>
        <:subtitle>
          <%= gettext("don't have an account?") %>
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Sign up <%= gettext("sign up") %>
          </.link>
          <%= gettext("for an account now.") %>
        </:subtitle>
      </.header>

      <.simple_form
        :let={f}
        id="login_form"
        for={:user}
        action={~p"/users/log_in"}
        as={:user}
        phx-update="ignore"
      >
        <.input field={{f, :email}} type="email" label={gettext("email")} required />
        <.input field={{f, :password}} type="password" label={gettext("password")} required />

        <:actions :let={f}>
          <.input field={{f, :remember_me}} type="checkbox" label={gettext("keep me logged in")} />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            <%= gettext("forgot your password?") %>
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with={gettext("signing in...")} class="w-full">
            <%= gettext("sign in") %> <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount_default(socket, reply, params \\ []) do
    {reply,
     assign(
       socket,
       Keyword.merge(
         [
           page_title: "login",
           scramble: Cube.scramble()
         ],
         params
       )
     )}
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    mount_default(assign(socket, email: email), :ok, temporary_assigns: [email: nil])
  end
end
