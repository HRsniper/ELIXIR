# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :aula42_auth_me,
  ecto_repos: [Aula42AuthMe.Repo]

config :aula42_auth_me, Aula42AuthMe.Guardian,
  issuer: "aula42_auth_me",
  secret_key: ""

# Configures the endpoint
config :aula42_auth_me, Aula42AuthMeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kjH92i9elUoXZqW8gCr+c73y3dV870ku/H9W28MaPYURtB3mwyxBh5puOB/Z7hHv",
  render_errors: [view: Aula42AuthMeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Aula42AuthMe.PubSub,
  live_view: [signing_salt: "45FMcVlF"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
