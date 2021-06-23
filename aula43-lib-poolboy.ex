# Você pode esgotar facilmente os recursos do sistema se não limitar o número máximo de processos simultâneos
# que seu programa pode gerar. Poolboy é uma biblioteca de pool genérica leve e amplamente usada para
# Erlang que resolve esse problema.
# (https://github.com/devinus/poolboy)
# (https://hex.pm/packages/poolboy)

# Por quê usar Poolboy? Vamos pensar em um exemplo específico por um momento.
# Você tem a tarefa de criar um aplicativo para salvar informações de perfil de usuário no banco de dados.
# Se você criou um processo para cada registro de usuário, você criaria um número ilimitado de conexões.
# Em algum momento, essas conexões começam a competir pelos recursos limitados disponíveis em seu servidor
# de banco de dados. Eventualmente seu aplicativo obtém tempos limite e várias exceções devido à
# sobrecarga dessa contenção.

# A solução para esse problema é usar um conjunto de gerenciadores (processos) para limitar o número de conexões
# em vez de criar um processo para cada registro de usuário. Então você pode facilmente evitar ficar
# sem seus recursos do sistema.
# É aí que entra Poolboy. Ele cria um pool de serviços gerenciados por um Supervisor sem nenhum esforço
# de sua parte para fazê-lo manualmente. Há muitas bibliotecas que usam Poolboy por baixo dos panos.
# Por exemplo, o pool de conexões do postgrex (que é alavancado pelo Ecto ao usar o PostgreSQL)
# e o redis_poolex (Redis connection pool) são algumas bibliotecas populares que usam o Poolboy.

# Primeiro vamos criar uma aplicação:
$ mix new aula43_poolboy --sup

# e então Adicione o Poolboy como uma dependência
# em aula43_poolboy\mix.exs
defp deps do
  [
    {:poolboy, "~> 1.5"}
  ]
end

# baixando as dependências e  compilando
$ mix do deps.get, compile

# As opções de configuração
# Precisamos saber um pouco sobre as várias opções de configuração para começar a usar o Poolboy.
#  :name - o nome do pool. O escopo pode ser :local, :global, ou :via.
#  :worker_module - o módulo que representa o gerenciador.
#  :size - tamanho máximo de pool.
#  :max_overflow - número máximo de gerenciadores temporários criados se o pool estiver vazio. (opcional)
#  :strategy - :lifo ou :fifo, determina se os gerenciadores registados devem ser colocados primeiro
#    ou último na linha dos gerenciadores disponíveis. O padrão é :lifo. (opcional)

# Configurando o Poolboy
# vamos criar um pool de gerenciadores responsáveis pelo processamento de pedidos para calcular a raiz quadrada
# de um número. Vamos manter o exemplo simples para que possamos manter nosso foco no Poolboy.
# Vamos definir as opções de configuração do Poolboy e adicioná-lo como um gerenciador filho
# como parte do nosso início do aplicativo.

# em lib\aula43_poolboy\application.ex
...
  defp poolboy_config do
    [
      name: {:local, :worker},
      worker_module: Aula43Poolboy.Worker,
      size: 5,
      max_overflow: 2
    ]
  end

  def start(_type, _args) do
    children = [
      :poolboy.child_spec(:worker, poolboy_config())
    ]

    opts = [strategy: :one_for_one, name: Aula43Poolboy.Supervisor]
    Supervisor.start_link(children, opts)
  end
...

# A primeira coisa que definimos são as opções de configuração para o pool.
# Nós nomeamos nosso pool ':worker' e definimos o ':scope' para ':local'.
# Então nós designamos o módulo Aula43Poolboy.Worker como o :worker_module que esse pool deve usar.
# Nós também definimos o ':size' do pool para um total de 5 gerenciadores.
# Também, caso todos os gerenciadores estejam sob carga, nós dizemos para ele criar mais 2 gerenciadores
# para ajudar na carga usando a opção ':max_overflow'.
# (Os gerenciadores de overflow vão embora uma vez que terminam seu trabalho.)

# Em seguida, adicionamos a função ':poolboy.child_spec/2' à matriz de filhos para que o pool de gerenciadores
# seja iniciado quando a aplicação for iniciada.
# Ele recebe dois argumentos: o nome do pool e a configuração do pool.

# vamos criar O módulo que referenciamos em ':worker_module' para fazer o gerenciamento,
# será um GenServer simples calculando a raiz quadrada de um número,
# dormindo por um segundo e imprimindo o pid do gerenciador.

# em lib\aula43_poolboy\worker.ex
defmodule Aula43Poolboy.Worker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:square_root, x}, _from, state) do
    IO.puts("process #{inspect(self())} calculating square root of #{x}")
    Process.sleep(1000)
    {:reply, :math.sqrt(x), state}
  end
end

# Agora que temos o nosso PoolboyApp.Worker, podemos testar o Poolboy.
# Vamos criar um módulo simples que cria processos simultâneos usando o Poolboy.
# ':poolboy.transaction/3' é a função que usamos para interagir com o poll de gerenciadores.

# em lib\aula43_poolboy\app.ex
defmodule Aula43Poolboy.App do
  @timeout 60_000

  def start do
    1..20
    |> Enum.map(fn i -> async_call_square_root(i) end)
    |> Enum.each(fn task -> await_and_inspect(task) end)
  end

  defp async_call_square_root(i) do
    Task.async(fn ->
      :poolboy.transaction(
        :worker,
        fn pid -> GenServer.call(pid, {:square_root, i}) end,
        @timeout
      )
    end)
  end

  defp await_and_inspect(task), do: task |> Task.await(@timeout) |> IO.inspect()
end

# vamos executar a aplicação em modo interativo
$ iex -S mix

iex> Aula43Poolboy.App.start()
# process #PID<0.213.0> calculating square root of 3
# process #PID<0.211.0> calculating square root of 5
# process #PID<0.215.0> calculating square root of 1
# process #PID<0.214.0> calculating square root of 2
# process #PID<0.212.0> calculating square root of 4
# process #PID<0.238.0> calculating square root of 6
# process #PID<0.239.0> calculating square root of 7
# process #PID<0.239.0> calculating square root of 8
# process #PID<0.238.0> calculating square root of 9
# process #PID<0.211.0> calculating square root of 10
# process #PID<0.215.0> calculating square root of 11
# process #PID<0.214.0> calculating square root of 12
# process #PID<0.212.0> calculating square root of 13
# process #PID<0.213.0> calculating square root of 14
# 1.0
# 1.4142135623730951
# 1.7320508075688772
# 2.0
# 2.23606797749979
# 2.449489742783178
# 2.6457513110645907
# process #PID<0.213.0> calculating square root of 15
# process #PID<0.239.0> calculating square root of 16
# process #PID<0.238.0> calculating square root of 17
# process #PID<0.211.0> calculating square root of 18
# process #PID<0.215.0> calculating square root of 19
# process #PID<0.214.0> calculating square root of 20
# 2.8284271247461903
# 3.0
# 3.1622776601683795
# 3.3166247903554
# 3.4641016151377544
# 3.605551275463989
# 3.7416573867739413
# 3.872983346207417
# 4.0
# 4.123105625617661
# 4.242640687119285
# 4.358898943540674
# 4.47213595499958
# :ok
