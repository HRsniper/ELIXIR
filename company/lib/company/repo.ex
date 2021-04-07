defmodule Company.Repo do
  use Ecto.Repo,
    otp_app: :company,
    adapter: Ecto.Adapters.Postgres
end
