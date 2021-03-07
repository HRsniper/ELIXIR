# Concorrência OTP tem um controle maior do que as abstrações de concorrência do Elixir


# GenServer
# Um servidor OTP é um módulo com o comportamento GenServer que implementa uma série de callbacks.
# No nível mais básico, um GenServer é um único processo que roda um loop que processa uma mensagem
# por interação passando para frente um estado atualizado.
# https://hexdocs.pm/elixir/GenServer.html#summary

# start_link(module, init_arg, options \\ []) function
  # Inicia um processo `GenServer` vinculado ao processo atual.

# init(init_arg) callback
  # Chamado quando o servidor é iniciado. `start_link/3` ou` start/3` irá bloquear até retornar.

# precisamos iniciar e processar a inicialização do GenServer.
# criar um link entre processos `GenServer.start_link/3`, Nós passamos para o módulo GenServer que estamos iniciando
# os argumentos iniciais e uma lista de opções. Os argumentos são passados para `GenServer.init/1` que
# configura o estado inicial através de seu valor de retorno.
iex> defmodule Queue do
  use GenServer

  @doc """
    Inicie nossa fila e conecte-a. Esta e uma funcao auxiliar
  """
  def start_link(state \\ []) do
    # GenServer.start_link/3 function
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
    GenServer.init/1 callback
  """
  def init(state), do: {:ok, state}
end

# Funções síncronas
# É geralmente necessário a interação com GenServers de uma maneira síncrona, chamando a função e esperando por sua resposta.
  # recebe a requisição, o PID do processo que chamou, um estado existente
# handle_call(request, from, state) callback
# invoca 'call/3' para lidar com mensagens de chamadas síncronas
# ´call/3´ irá bloquear até que uma resposta seja recebida (a menos que a chamada expire ou os nós sejam desconectados).
# Retornando {:reply, reply, new_state} envia a resposta `reply` ao chamador e continua o loop com novo estado `new_state`.

iex> defmodule Queue do
  use GenServer

  @doc """
    Inicie nossa fila e conecte-a. Esta e uma funcao auxiliar
  """
  def start_link(state \\ []) do
    # GenServer.start_link/3 function
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

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

  ### Client API / Helper functions

  def queue, do: GenServer.call(__MODULE__, :queue)
  def dequeue, do: GenServer.call(__MODULE__, :dequeue)
end

# call(server, request, timeout \\ 5000) function
# Faz uma chamada síncrona para o server e aguarda sua resposta.

iex> Queue.start_link([1, 2, 3])
# {:ok, #PID<0.158.0>}
iex> Queue.dequeue()
# 1
iex> Queue.dequeue()
# 2
iex> Queue.queue()
# [3]
iex> Queue.dequeue()
# 3
iex> Queue.queue()
# []
iex> Queue.dequeue()
# nil
iex> Queue.queue()
# []

# cast(server, request) function
# Envia uma solicitação assíncrona para o server.

# handle_cast(request, state) callback
# Invoca `cast/2` para lidar com mensagens assíncronas.
# Retorna {:noreply, new_state} continua o loop com novo estado `new_state`.

# Funções assíncronas
# requisições assíncronas são processadas pelo callback `handle_cast/2`.
# mas não recebe o PID do processo que chama e não é esperada resposta.

iex> defmodule Queue do
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

iex> Queue.start_link([1, 2, 3])
# {:ok, #PID<0.158.0>}
iex> Queue.dequeue()
# 1
iex> Queue.dequeue()
# 2
iex> Queue.queue()
# [3]
iex> Queue.enqueue(20)
# :ok
iex> Queue.queue()
# [3, 20]
