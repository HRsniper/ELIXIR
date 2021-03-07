defmodule SimpleQueue do
  @moduledoc """
    Implemetacao de SimpleQueue
  """
  use GenServer

  # GenServer API

  @doc """
    GenServer.init/1 callback
  """
  def init(state), do: {:ok, state}

  @doc """
    GenServer.handle_call/3 callback
  """
  def handle_call(:dequeue, _from, [value | state]), do: {:reply, value, state}

  def handle_call(:dequeue, _from, []), do: {:reply, nil, []}

  def handle_call(:queue, _from, state), do: {:reply, state, state}

  @doc """
    GenServer.handle_cast/2 callback
  """
  def handle_cast({:enqueue, value}, state), do: {:noreply, state ++ [value]}

  # Client API / Helper functions

  @doc """
    Inicie nossa fila e conecte-a. Esta e uma funcao auxiliar
  """
  def start_link(state \\ []) do
    # GenServer.start_link/3 function
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def queue, do: GenServer.call(__MODULE__, :queue)
  def dequeue, do: GenServer.call(__MODULE__, :dequeue)
  def enqueue(value), do: GenServer.cast(__MODULE__, {:enqueue, value})
end
