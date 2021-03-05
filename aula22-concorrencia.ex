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
# E se não queremos vincular dois processos, mas continuar a sermos informados?
# Para isso, podemos usar o monitoramento de processos com `spawn_monitor`.
# Quando monitoramos um processo, nós recebemos uma mensagem informando se o processo falhou,
# sem afetar nosso processo atual nem necessitar explicitamente interceptar a saída.
  # spawn_monitor(fun) {pid(), reference()}
    # Gera a função fornecida `fun`, monitora-a e retorna seu PID e referência de monitoramento.
  # spawn_monitor(module, fun, args)
    # Gera o módulo `module` e a função `fun` fornecidos passando os argumentos fornecidos `args`,
    # monitora e retorna seu PID e referência de monitoramento.

iex> defmodule Example do
  def explode, do: exit(:kaboom)
end

iex> {pid, ref} = spawn_monitor(Example, :explode, [])
{#PID<0.177.0>, #Reference<0.311732244.798752769.220970>}

iex> defmodule Example do
  def explode, do: exit(:kaboom)

  def run do
    {pid, ref} = spawn_monitor(Example, :explode, [])

    receive do
      {:DOWN, ref, :process, from_pid, reason} -> IO.puts("Exit ref: #{inspect ref}, pid: #{inspect from_pid}, reason: #{reason}")
    end
  end
end

iex> Example.run()
# Exit ref: #Reference<0.311732244.798752769.221072>, pid: #PID<0.195.0>, reason: kaboom
# :ok

# Agentes
# Agentes são uma abstração acerca de processos em segundo plano que mantêm estado.
# Podemos acessá-los de outros processos dentro de nossa aplicação ou nó.
# O estado do nosso Agente é definido como valor de retorno de nossa função:
# resto das funções https://hexdocs.pm/elixir/Agent.html#summary

  # start_link(fun, options \\ [])
    # Inicia um agente vinculado ao processo atual com a função dada. retorna o {ok, pid} caso error,{error, {:already_started, pid}
    # Isso geralmente é usado para iniciar o agente como parte de uma árvore de supervisão.
  # start_link (module, fun, args, options \\ [])
    # Inicia um agente vinculado ao processo atual. a função `fun` no módulo `module` será chamada com
    # os argumentos fornecidos `args` para inicializar o estado.
iex> {:ok, agent} = Agent.start_link(fn -> [1, 2, 3] end)
{:ok, #PID<0.213.0>}

iex> defmodule Example do
  def show(args), do: "#{args}"
  def sum(state, args), do: state + args
end

iex> {:ok, agent2} = Agent.start_link(Example, :show, [123], [])
# {:ok, #PID<0.229.0>}

  # update (agent, fun, timeout \\ 5000)
    # Atualiza o estado do agente por meio da função anônima fornecida.
    # A função `fun` é enviada ao agente que invoca a função passando o estado do agente.
    # O valor de retorno da função `fun` torna-se o novo estado do agente.
    # Esta função sempre retorna: ok.
    # Se nenhum resultado for recebido dentro do tempo especificado, a chamada de função falha e o chamador sai.
  # update (agent, module, fun, args, timeout \\ 5000)
    # Atualiza o estado do agente por meio da função fornecida.
    # O estado `agent` é adicionado como primeiro argumento, a função `fun` no módulo `module` será chamada com
    # os argumentos fornecidos `args` para Atualizar o estado.
iex> Agent.update(agent, fn (state) -> state ++ [4, 5] end)
# :ok
iex> {:ok, agent2} = Agent.start_link(Example, :sum, [0, 1], [])
iex> Agent.update(agent2, Example, :sum, [2])
# :ok

  # get (agent, fun, timeout \\ 5000)
    # Obtém um valor de agente por meio da função anônima fornecida.
    # A função `fun` é enviada ao agente que invoca a função passando o estado do agente.
    # O resultado da chamada de função é retornado desta função.
    # Se nenhum resultado for recebido dentro do tempo especificado, a chamada de função falha e o chamador sai.
iex> {:ok, pid3} = Agent.start_link(fn -> 42 end)
iex> Agent.get(pid3, fn state -> state end)
# 42
iex> Agent.get(agent, &(&1))
# [1, 2, 3, 4, 5]
iex> Agent.get(agent2, &(&1))
# 3

# A opção :name é usada para nomeamos um Agente. podemos referenciar seu nome ao invés de seu PID
# iex> Agent.start_link(fn -> [3, 2, 1] end, [name: Numbers])
iex> Agent.start_link(fn -> [3, 2, 1] end, name: Numbers)
{:ok, #PID<0.74.0>}

# iex> Agent.get(Numbers, fn state -> state end)
iex> Agent.get(Numbers, &(&1))
# [3, 2, 1]

# Tarefas
# Tarefas fornecem uma forma para executar uma função em segundo plano e posteriormente recuperar seu valor.
# Elas podem ser particularmente úteis ao manusear operações custosas, sem bloquear a execução do aplicativo.
# O caso de uso mais comum para tarefas é converter código sequencial em código simultâneo
# calculando um valor de forma assíncrona
  # async(fun)
    # Inicia uma tarefa que deve ser aguardada, pelo processo do chamador (e apenas pelo chamador)
  # async(module, function_name, args)
  # a função `fun` no módulo `module` será chamada com os argumentos fornecidos `args` para aguardar.
  # await(task, timeout \\ 5000)
    # Aguarda uma resposta da tarefa e a retorna. é usado para ler a mensagem enviada pela tarefa `async`.
  # yield(task, timeout \\ 5000)
    # é uma alternativa para `await` onde o chamador irá bloquear temporariamente, esperando até que a tarefa responda ou trave.
# resto das funções https://hexdocs.pm/elixir/Task.html#summary
iex> task = Task.async(fn -> 1 + 10 end)
# %Task{
#   owner: #PID<0.101.0>,
#   pid: #PID<0.132.0>,
#   ref: #Reference<0.875837400.4040425474.186919>
# }
iex> task2 = Task.async(fn -> 1 + 10 end)
iex> Task.await(task2) + Task.await(task)
# 22

# :timer.sleep(ms)
# http://erlang.org/doc/man/timer.html#sleep-1
# Suspende o processo da função chamada por milissegundos de tempo e
# depois retorna :ok ou suspende o processo para sempre se o tempo for o :infinity.
# Naturalmente, essa função não retorna imediatamente.
iex> defmodule Example do
      def double(x) do
        :timer.sleep(x)
        # :timer.sleep(2000)
        x * 2
      end
    end
iex> task = Task.async(Example, :double, [10000])
# %Task{
#   owner: #PID<0.101.0>,
#   pid: #PID<0.168.0>,
#   ref: #Reference<0.875837400.4040425474.187133>
# }

# Realizar algum trabalho sem atrapalhar o que ja esta sendo feito

iex> Task.await(task) # await 10s
# 20000
