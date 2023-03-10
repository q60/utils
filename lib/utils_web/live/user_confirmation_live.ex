defmodule UtilsWeb.UserConfirmationLive do
  use UtilsWeb, :live_view

  alias Utils.Accounts
  alias Helpers.Cube

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center"><%= gettext("confirm account") %></.header>

      <.simple_form :let={f} for={:user} id="confirmation_form" phx-submit="confirm_account">
        <.input field={{f, :token}} type="hidden" value={@token} />
        <:actions>
          <.button phx-disable-with={gettext("confirming...")} class="w-full">
            <%= gettext("confirm my account") %>
          </.button>
        </:actions>
      </.simple_form>

      <p class="text-center mt-4">
        <.link href={~p"/users/register"}><%= gettext("register") %></.link>
        |
        <.link href={~p"/users/log_in"}><%= gettext("register") %></.link>
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
           page_title: "confirmation",
           scramble: Cube.scramble()
         ],
         params
       )
     )}
  end

  def mount(params, _session, socket) do
    mount_default(assign(socket, token: params["token"]), :ok, temporary_assigns: [token: nil])
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def handle_event("confirm_account", %{"user" => %{"token" => token}}, socket) do
    case Accounts.confirm_user(token) do
      {:ok, _} ->
        mount_default(
          socket
          |> put_flash(:info, gettext("user confirmed successfully."))
          |> redirect(to: ~p"/"),
          :noreply
        )

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            mount_default(redirect(socket, to: ~p"/"), :noreply)

          %{} ->
            mount_default(
              socket
              |> put_flash(
                :error,
                gettext("user confirmation link is invalid or it has expired.")
              )
              |> redirect(to: ~p"/"),
              :noreply
            )
        end
    end
  end
end
