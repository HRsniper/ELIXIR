defmodule Aula48Mox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      Aula48MoxWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Aula48Mox.PubSub},
      # Start the Endpoint (http/https)
      Aula48MoxWeb.Endpoint
      # Start a worker by calling: Aula48Mox.Worker.start_link(arg)
      # {Aula48Mox.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Aula48Mox.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Aula48MoxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
