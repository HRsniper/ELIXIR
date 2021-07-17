defmodule Aula46DistilleryPhoenix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Aula46DistilleryPhoenix.Repo,
      # Start the Telemetry supervisor
      Aula46DistilleryPhoenixWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Aula46DistilleryPhoenix.PubSub},
      # Start the Endpoint (http/https)
      Aula46DistilleryPhoenixWeb.Endpoint
      # Start a worker by calling: Aula46DistilleryPhoenix.Worker.start_link(arg)
      # {Aula46DistilleryPhoenix.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Aula46DistilleryPhoenix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Aula46DistilleryPhoenixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
