defmodule GenstageExample.Producer do
  use GenStage

  @doc """
  GenStage.start_link/3
  Inicia um processo GenStage vinculado ao processo atual.
  """
  def start_link(initial \\ 0) do
    GenStage.start_link(__MODULE__, initial, name: __MODULE__)
  end

  @doc """
  init/1
  invocado quando o servidor é iniciado.
  """
  def init(counter), do: {:producer, counter}

  @doc """
  handle_demand/2
  invocado em estágio de :producer.
  """
  def handle_demand(demand, state) do
    events = Enum.to_list(state..(state + demand - 1))
    {:noreply, events, state + demand}
  end
end
