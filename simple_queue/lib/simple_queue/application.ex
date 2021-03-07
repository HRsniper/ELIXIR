defmodule SimpleQueue.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: SimpleQueue.Worker.start_link(arg)
      # {SimpleQueue.Worker, arg}

      # SimpleQueue
      {SimpleQueue, [1, 2, 3]}
      # {Task.Supervisor, name: SimpleQueue.TaskSupervisor, restart: :transient}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SimpleQueue.Supervisor]
    # Supervisor.start_link(children, opts)

    DynamicSupervisor.start_link(opts)
    # {:ok, pid} = DynamicSupervisor.start_child(SimpleQueue.Supervisor, SimpleQueue)

    # {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

  end
end
