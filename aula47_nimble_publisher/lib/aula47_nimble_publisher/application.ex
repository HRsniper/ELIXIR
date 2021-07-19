defmodule Aula47NimblePublisher.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      Aula47NimblePublisherWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Aula47NimblePublisher.PubSub},
      # Start the Endpoint (http/https)
      Aula47NimblePublisherWeb.Endpoint
      # Start a worker by calling: Aula47NimblePublisher.Worker.start_link(arg)
      # {Aula47NimblePublisher.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Aula47NimblePublisher.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Aula47NimblePublisherWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
