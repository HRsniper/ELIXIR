defmodule GenstageExample.ProducerConsumer do
  use GenStage

  require Integer

  @doc """
  GenStage.start_link/3
  Inicia um processo GenStage vinculado ao processo atual.
  """
  def start_link(_initial) do
    GenStage.start_link(__MODULE__, :state_doesnt_matter, name: __MODULE__)
  end

  @doc """
  init/1
  invocado quando o servidor é iniciado.
  """
  def init(state) do
    {:producer_consumer, state, subscribe_to: [GenstageExample.Producer]}
  end

  @doc """
  handle_events/3
  Invocado nos estágios :producer_consumer e :consumer para manipular eventos.
  """
  def handle_events(events, _from, state) do
    numbers =
      events
      |> Enum.filter(&Integer.is_even/1)

    {:noreply, numbers, state}
  end
end
