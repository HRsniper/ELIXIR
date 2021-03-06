defmodule Aula36Plug.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Aula36Plug.Worker.start_link(arg)
      # {Aula36Plug.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: Aula36Plug.Router, options: [port: cowboy_port()]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Aula36Plug.Supervisor]

    Logger.info("Starting application...")

    Supervisor.start_link(children, opts)
  end

  defp cowboy_port, do: Application.get_env(:aula36_plug, :cowboy_port, 8080)
end
