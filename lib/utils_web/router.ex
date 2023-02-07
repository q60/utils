defmodule UtilsWeb.Router do
  use UtilsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {UtilsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UtilsWeb do
    pipe_through :browser

    live "/", UtilsLive.Index, :index
    live "/pie", UtilsLive.PieChart, :pie_chart
    live "/todo", UtilsLive.ToDo, :to_do
    live "/short", UtilsLive.Shortener, :shortener
    live "/bin", UtilsLive.CodeBin, :code_bin

    get "/s/:short", PageController, :shortener_path
    get "/c/:short", PageController, :bin_path
    get "/c/raw/:short", PageController, :bin_path_raw
  end

  # Other scopes may use custom stacks.
  # scope "/api", UtilsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:utils, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: UtilsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
