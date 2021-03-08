defmodule A25Chat.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: A25Chat.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: A25Chat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
