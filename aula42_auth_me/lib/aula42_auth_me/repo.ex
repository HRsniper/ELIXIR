defmodule Aula42AuthMe.Repo do
  use Ecto.Repo,
    otp_app: :aula42_auth_me,
    adapter: Ecto.Adapters.Postgres
end
