# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :aula46_distillery_phoenix,
  ecto_repos: [Aula46DistilleryPhoenix.Repo]

# Configures the endpoint
config :aula46_distillery_phoenix, Aula46DistilleryPhoenixWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "xatJXIOu5ombmo4sB2O4pKuqEaJ4TaYdb0oQpPaU7yDGWLFmwW6y++m8WG51K3hV",
  render_errors: [view: Aula46DistilleryPhoenixWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Aula46DistilleryPhoenix.PubSub,
  live_view: [signing_salt: "Eo8nQzNt"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
