defmodule UtilsWeb.UserSettingsLive do
  use UtilsWeb, :live_view

  alias Utils.Accounts
  alias Utils.Settings
  alias Utils.Settings.Setting
  alias Helpers.Cube

  import UtilsWeb.CustomComponents, only: [submit_button: 1]

  def render(assigns) do
    ~H"""
    <div class="text-4xl font-['Fira_Code_SemiBold'] mb-8">
      <h1><%= gettext("general") %></h1>
    </div>

    <.simple_form :let={f} for={@settings_changeset} phx-submit="update_settings">
      <label class="text-lg font-['Fira_Code']"><%= gettext("language") %></label>
      <.input
        field={{f, :language}}
        value={Gettext.get_locale(UtilsWeb.Gettext)}
        list="language"
        class="!text-lg font-['Iosevka_Term_Slab'] bg-purple-50 rounded-none !my-4 !w-[20%]"
      />
      <datalist id="language">
        <%= for lang <- Gettext.known_locales(UtilsWeb.Gettext) do %>
          <option value={lang} />
        <% end %>
      </datalist>

      <:actions>
        <.submit_button disable_with={gettext("changing...")}>
          <%= gettext("change settings") %>
        </.submit_button>
      </:actions>
    </.simple_form>

    <div class="text-4xl font-['Fira_Code_SemiBold'] my-8">
      <h1><%= gettext("change email") %></h1>
    </div>

    <.simple_form
      :let={f}
      id="email_form"
      for={@email_changeset}
      phx-submit="update_email"
      phx-change="validate_email"
    >
      <.error :if={@email_changeset.action == :insert}>
        <%= gettext("something went wrong! please check the errors below.") %>
      </.error>

      <label class="text-lg font-['Fira_Code']"><%= gettext("email") %></label>
      <.input
        field={{f, :email}}
        type="email"
        class="!text-lg font-['Iosevka_Term_Slab'] bg-purple-50 rounded-none !my-4"
        required
      />

      <label class="text-lg font-['Fira_Code']"><%= gettext("current password") %></label>
      <.input
        field={{f, :current_password}}
        name="current_password"
        id="current_password_for_email"
        type="password"
        value={@email_form_current_password}
        class="!text-lg font-['Iosevka_Term_Slab'] bg-purple-50 rounded-none !my-4"
        required
      />

      <:actions>
        <.submit_button disable_with={gettext("changing...")}>
          <%= gettext("change email") %>
        </.submit_button>
      </:actions>
    </.simple_form>

    <div class="text-4xl font-['Fira_Code_SemiBold'] my-8">
      <h1><%= gettext("change password") %></h1>
    </div>

    <.simple_form
      :let={f}
      id="password_form"
      for={@password_changeset}
      action={~p"/users/log_in?_action=password_updated"}
      method="post"
      phx-change="validate_password"
      phx-submit="update_password"
      phx-trigger-action={@trigger_submit}
    >
      <.error :if={@password_changeset.action == :insert}>
        <%= gettext("something went wrong! please check the errors below.") %>
      </.error>

      <.input field={{f, :email}} type="hidden" value={@current_email} />

      <label class="text-lg font-['Fira_Code']"><%= gettext("new password") %></label>
      <.input
        field={{f, :password}}
        type="password"
        class="!text-lg font-['Iosevka_Term_Slab'] bg-purple-50 rounded-none !my-4"
        required
      />

      <label class="text-lg font-['Fira_Code']"><%= gettext("confirm new password") %></label>
      <.input
        field={{f, :password_confirmation}}
        type="password"
        class="!text-lg font-['Iosevka_Term_Slab'] bg-purple-50 rounded-none !my-4"
      />

      <label class="text-lg font-['Fira_Code']"><%= gettext("current password") %></label>
      <.input
        field={{f, :current_password}}
        name="current_password"
        type="password"
        id="current_password_for_password"
        value={@current_password}
        class="!text-lg font-['Iosevka_Term_Slab'] bg-purple-50 rounded-none !my-4"
        required
      />

      <:actions>
        <.submit_button disable_with={gettext("changing...")}>
          <%= gettext("change password") %>
        </.submit_button>
      </:actions>
    </.simple_form>
    """
  end

  def mount_default(socket, reply, params \\ []) do
    changeset = Setting.changeset(%Setting{}, %{})

    {reply,
     assign(
       socket,
       Keyword.merge(
         [
           page_title: "settings",
           settings_changeset: changeset,
           scramble: Cube.scramble()
         ],
         params
       )
     )}
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, gettext("email changed successfully."))

        :error ->
          put_flash(socket, :error, gettext("email change link is invalid or it has expired."))
      end

    mount_default(push_navigate(socket, to: ~p"/users/settings"), :ok)
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_changeset, Accounts.change_user_email(user))
      |> assign(:password_changeset, Accounts.change_user_password(user))
      |> assign(:trigger_submit, false)

    mount_default(socket, :ok)
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    email_changeset = Accounts.change_user_email(socket.assigns.current_user, user_params)

    socket =
      assign(socket,
        email_changeset: Map.put(email_changeset, :action, :validate),
        email_form_current_password: password
      )

    mount_default(socket, :noreply)
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = gettext("a link to confirm your email change has been sent to the new address.")
        mount_default(put_flash(socket, :info, info), :noreply)

      {:error, changeset} ->
        mount_default(
          assign(socket, :email_changeset, Map.put(changeset, :action, :insert)),
          :noreply
        )
    end
  end

  def handle_event("update_settings", %{"setting" => %{"language" => lang}}, socket) do
    user = socket.assigns.current_user.email |> Base.encode64()

    Settings.change(user, :language, lang)
    mount_default(socket, :noreply)
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    password_changeset = Accounts.change_user_password(socket.assigns.current_user, user_params)

    mount_default(
      socket
      |> assign(:password_changeset, Map.put(password_changeset, :action, :validate))
      |> assign(:current_password, password),
      :noreply
    )
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        socket =
          socket
          |> assign(:trigger_submit, true)
          |> assign(:password_changeset, Accounts.change_user_password(user, user_params))

        mount_default(socket, :noreply)

      {:error, changeset} ->
        mount_default(assign(socket, :password_changeset, changeset), :noreply)
    end
  end
end
