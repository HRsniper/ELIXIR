# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :aula47_nimble_publisher, Aula47NimblePublisherWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YYl6NriJW8mooafXnOUK+oY6HFVgOY9pGVzCW3/EZco6ur/9n4Ovgq7hJ3WoYOaO",
  render_errors: [view: Aula47NimblePublisherWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Aula47NimblePublisher.PubSub,
  live_view: [signing_salt: "iYdb8afN"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
