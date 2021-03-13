defmodule GenstageExample.Application do
  use Application
  # import Supervisor, warn: false

  @impl true
  def start(_type, _args) do
    # children = [
    #   {GenstageExample.Producer, 0},
    #   {GenstageExample.ProducerConsumer, []},
    #   {GenstageExample.Consumer, []}
    # ]

    children = [
      {GenstageExample.Producer, 0},
      {GenstageExample.ProducerConsumer, []},
      %{
        id: 1,
        start: {GenstageExample.Consumer, :start_link, [[]]}
      },
      %{
        id: 2,
        start: {GenstageExample.Consumer, :start_link, [[]]}
      },
    ]

    opts = [strategy: :one_for_one, name: GenstageExample.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
