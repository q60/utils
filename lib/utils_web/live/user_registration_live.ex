defmodule UtilsWeb.UserRegistrationLive do
  use UtilsWeb, :live_view

  alias Utils.Accounts
  alias Utils.Accounts.User
  alias Helpers.Cube

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        <%= gettext("register for an account") %>
        <:subtitle>
          <%= gettext("already registered?") %>
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            <%= gettext("sign in") %>
          </.link>
          <%= gettext("to your account now.") %>
        </:subtitle>
      </.header>

      <.simple_form
        :let={f}
        id="registration_form"
        for={@changeset}
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
        as={:user}
      >
        <.error :if={@changeset.action == :insert}>
          <%= gettext("something went wrong! please check the errors below.") %>
        </.error>

        <.input field={{f, :email}} type="email" label={gettext("email")} required />
        <.input field={{f, :password}} type="password" label={gettext("password")} required />

        <:actions>
          <.button phx-disable-with={gettext("creating account...")} class="w-full">
            <%= gettext("create an account") %>
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
           page_title: "registration",
           scramble: Cube.scramble()
         ],
         params
       )
     )}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})
    socket = assign(socket, changeset: changeset, trigger_submit: false)
    mount_default(socket, :ok, temporary_assigns: [changeset: nil])
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        mount_default(assign(socket, trigger_submit: true, changeset: changeset), :noreply)

      {:error, %Ecto.Changeset{} = changeset} ->
        mount_default(assign(socket, :changeset, changeset), :noreply)
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    mount_default(assign(socket, changeset: Map.put(changeset, :action, :validate)), :noreply)
  end
end
