defmodule Aula45Bypass.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Aula45Bypass.Worker.start_link(arg)
      # {Aula45Bypass.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Aula45Bypass.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
