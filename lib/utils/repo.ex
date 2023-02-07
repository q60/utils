defmodule Utils.Repo do
  use Ecto.Repo,
    otp_app: :utils,
    adapter: Ecto.Adapters.Postgres
end
