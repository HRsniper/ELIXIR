# Elixir suporta concorrência, Graças à Erlang VM (BEAM), com isso a
# concorrência no Elixir é mais fácil do que esperamos. O modelo de concorrência depende de Atores,
# um processo contido (isolado) que se comunica com outros processos por meio de passagem de mensagem.

# Processos
# Processos no Erlang VM são leves e executam em todas as CPUs.
# Enquanto eles podem parecer como threads nativas, eles são bastantes simples
# e não é incomum ter milhares de processos concorrentes em uma aplicação Elixir.

# A forma mais fácil para criar um novo processo é o spawn, que pode receber tanto uma
# função nomeada quanto uma anônima. Quando criamos um novo processo ele retorna um
# Process Identifier ou PID, para exclusivamente identificá-lo dentro de nossa aplicação.
  # spawn(fun)
    # Gera a função fornecida `fun` e retorna seu PID.
  # spawn(module, fun, args)
    # Gera a função fornecida `fun` a partir do módulo fornecido `module`,
    # passando os argumentos fornecidos `args` e retorna seu PID.

# Normalmente os desenvolvedores não usam as funções `spawn`, ao invés disso, eles usam abstrações
# como `Task`, `GenServer` e` Agent`, construídas em cima do `spawn`,
# que gera processos com mais conveniências em termos de introspecção e depuração.
# E o módulo `Process` para mais funções relacionadas ao processo.

iex> defmodule Example do
  def add(a, b) do
    IO.puts(a + b)
  end
end

iex> Example.add(2, 3)
# 5
# :ok

# Para executar a função de forma assíncrona usamos spawn/3
iex> spawn(Example, :add, [2, 3])
# 5
#PID<0.115.0>
iex> spawn(Example, :add, [2, 3])
# 5
#PID<0.117.0>

# Passagem de mensagem
# Para comunicar-se, os processos dependem de passagem de mensagens.
# Há dois componentes principais para isso `send/2` e `receive`.
# A função `send/2` nos permite enviar mensagens para PIDs.
# Para recebê-las, usamos a função `receive` com pattern matching para selecionar as mensagens.
# Se nenhum padrão coincidir com a mensagem recebida, a execução continua sem interrupções.
  # send(dest, message)
    # Envia uma mensagem para o destino fornecido `dest` e retorna a mensagem `message`.
  # receive(args)
  # Verifica se há uma mensagem que corresponda às cláusulas fornecidas na caixa de correio do processo atual.
  # Caso não exista tal mensagem, o processo atual trava até que uma mensagem chegue ou espera
  #  até um determinado valor de tempo limite.
  # Uma cláusula opcional after pode ser fornecida caso a mensagem não tenha sido recebida após o
  # período de tempo limite fornecido, especificado em milissegundos: (:infinity, 0, números inteiros)
    # after 5000 -> faça algo

iex> defmodule Example do
  def listen do
    receive do
      {:ok, "hello"} -> IO.puts("World")
    end

    # listen/0 é recursiva, isso permite que nosso processo receba múltiplas mensagens.
    # Sem recursão nosso processo teria saído depois de receber a primeira mensagem.
    listen()
  end
end

iex> pid = spawn(Example, :listen, [])
#PID<0.133.0>
iex> send(pid, {:ok, "hello"})
# World
# {:ok, "hello"}
iex> send pid, :ok
# :ok

iex> defmodule Example do
  def listen do
    receive do
      {:ok, "hello"} -> IO.puts("World")

      after
        5000 -> IO.puts("num metodo encontrado")
    end

    listen()
  end
end

# cada 5 segundos after é executado
iex> num metodo encontrado
iex> send(pid, {:ok, "hello"})
# World
# {:ok, "hello"}
iex> num metodo encontrado


# Vinculando Processos
# Um problema com `spawn` é saber quando um processo falha.
# Para isso, precisamos vincular nossos processos usando `spawn_link`.
# Dois processos vinculados receberão notificações de saída um do outro
  # spawn_link (fun)
    # Gera a função fornecida `fun`, vincula-a ao processo atual e retorna seu PID.
  # spawn_link (module, fun, args)
    # Gera a função fornecida `fun` pelo módulo fornecido `module`, passando os argumentos fornecidos `args`,
    # vincula-a ao processo atual e retorna seu PID.

iex> defmodule Example do
  def explode, do: exit(:kaboom)
end

iex> spawn(Example, :explode, [])
#PID<0.112.0>

iex> spawn_link(Example, :explode, [])
# ** (EXIT from #PID<0.101.0>) shell process exited with reason: :kaboom

# Em determinados momentos não queremos que nosso processo vinculado falhe o atual.
# Para isso nós precisamos interceptar as saídas usando `Process.flag/2`. (https://hexdocs.pm/elixir/Process.html#flag/2)
# Ela usa a função do erlang `process_flag/2` para a flag `trap_exit`.
# Quando interceptando saídas (trap_exit é definida como true),
# sinais de saída são recebidos como uma tupla de mensagem: {:EXIT, from_pid, reason}.
  # flag(flag, value)
    # Define o sinalizador fornecido `flag` para o valor do processo `value` de chamada.
    # Retorna o valor antigo do sinalizador `flag`.
  # flag(pid, flag, value)
    # Define o sinalizador fornecido `flag` para o valor do processo `value` do `pid` fornecido.
    # Retorna o valor antigo do sinalizador `flag`.

iex> defmodule Example do
  def explode, do: exit(:kaboom)

  def run do
    Process.flag(:trap_exit, true)
    spawn_link(Example, :explode, []) #PID<0.169.0>

    receive do
      # spawn_link/3 -> explode/0
      {:EXIT, from_pid, reason} -> IO.puts("Exit from: #{inspect(from_pid)}, reason: #{reason}")
    end
  end
end

iex> Example.run()
# Exit from: #PID<0.169.0>, reason: kaboom
# :ok

# Monitorando processos
