defmodule Aula43Poolboy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  defp poolboy_config do
    [
      name: {:local, :worker},
      worker_module: Aula43Poolboy.Worker,
      size: 5,
      max_overflow: 2
    ]
  end

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Aula43Poolboy.Worker.start_link(arg)
      # {Aula43Poolboy.Worker, arg}
      :poolboy.child_spec(:worker, poolboy_config())
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Aula43Poolboy.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
