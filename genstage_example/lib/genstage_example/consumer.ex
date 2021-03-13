defmodule GenstageExample.Consumer do
  use GenStage

  @doc """
  GenStage.start_link/3
  Inicia um processo GenStage vinculado ao processo atual.
  """
  def start_link(_initial) do
    GenStage.start_link(__MODULE__, :state_doesnt_matter)
  end

  @doc """
  init/1
  invocado quando o servidor é iniciado.
  """
  def init(state) do
    {:consumer, state, subscribe_to: [GenstageExample.ProducerConsumer]}
  end

  @doc """
  handle_events/3
  Invocado nos estágios :producer_consumer e :consumer para manipular eventos.
  """
  def handle_events(events, _from, state) do
    for event <- events do
      IO.inspect({self(), event, state})
    end

    # Como consumidores, nunca emitimos eventos
    {:noreply, [], state}
  end
end
