# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :aula48_mox, Aula48MoxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "dQQ6IszElBlOyXH97l7mT83rUb4zNAB4Mf/imFUPWdaHGl7as7U1hm8ME8gtxgRo",
  render_errors: [view: Aula48MoxWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Aula48Mox.PubSub,
  live_view: [signing_salt: "2qQLIfUZ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
