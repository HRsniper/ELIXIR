defmodule Aula42AuthMe.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Aula42AuthMe.Repo,
      # Start the Telemetry supervisor
      Aula42AuthMeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Aula42AuthMe.PubSub},
      # Start the Endpoint (http/https)
      Aula42AuthMeWeb.Endpoint
      # Start a worker by calling: Aula42AuthMe.Worker.start_link(arg)
      # {Aula42AuthMe.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Aula42AuthMe.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Aula42AuthMeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
