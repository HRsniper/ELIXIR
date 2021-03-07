# Supervisores OTP
# Supervisores são processos especializados com um propósito: monitorar outros processos.
# Estes supervisores nos possibilitam a criação de aplicações tolerantes a falhas,
# automaticamente reiniciando processos filhos quando eles falham.

# A magia de Supervisores está na função `Supervisor.start_link/2`.`
# Além de iniciar nosso supervisor e filhos, nos permite definir a
# estratégia que nosso supervisor irá usar para gerenciar os processos filhos.
# https://hexdocs.pm/elixir/Supervisor.html#summary

# start_link(children, options)
  # Inicia um supervisor com as crianças fornecidas `children`.

# start_link(module, init_arg, options \\ [])
# invoca `init/1` do `module`, com `init_arg` como argumentos
  # Inicia um processo de supervisor baseado em módulo com o módulo fornecido `module` e init_arg.

# se o supervisor e seus processos filhos são gerados com sucesso
# (se a função de início de cada processo filho retorna {:ok, child}.
# `start_link` retorna {:ok, pid}, onde `pid`` é o PID do supervisor.

# init (init_arg) callback
  # Callback invocado para iniciar o supervisor e durante as atualizações de código quentes.
# init(children, options) function
  # Recebe uma lista de filhos para inicializar e um conjunto de opções.
  # Isso normalmente é invocado no final do callback init/1 de supervisores baseados em módulo.
  # {:ok, tuple}
  # Esta função retorna uma tupla contendo os sinalizadores do supervisor e as especificações dos filhos.

# Criar um novo projeto com uma nova árvore de supervisão.
$ mix new simple_queue --sup
# O código do módulo Queue da aula24 deve ir em lib/simple_queue.ex
# e o código do supervisor que nós vamos adicionar vai em lib/simple_queue/application.ex

children = [
  # Filhos são definidos usando uma lista, pode ser uma lista com nome de módulos
  # SimpleQueue
  # ou uma lista de tuplas se você deseja incluir opções de configuração
  {SimpleQueue, [1, 2, 3]}
  # SimpleQueue é automaticamente iniciado com [1, 2, 3]
]

$ cd simple_queue/

$ iex -S mix

iex> SimpleQueue.queue
# [1, 2, 3]

# Se o nosso SimpleQueue fosse falhar ou ser encerrado, nosso Supervisor iria automaticamente
# reiniciar este processo como se nada tivesse acontecido.

# [strategy: :one_for_one]
# Estratégias
# Atualmente, existem três estratégias diferentes de reinicialização disponíveis aos supervisores:
  # :one_for_one - Apenas reinicia os processos filhos que falharem.
  # :one_for_all - Reinicia todos os processos filhos no evento da falha.
  # :rest_for_one - Reinicia o processo que falhou e qualquer processo que começou depois deste.


# Especificação dos filhos
# Depois que o supervisor iniciou, ele deve saber como iniciar/parar/reiniciar seus filhos.
# Cada módulo filho deve ter uma função `child_spec/2` para definir esses comportamentos.
# Os macros `use GenServer`, `use Supervisor` e `use Agent` automaticamente definem esse método para nós
# (SimpleQueue usa use GenServer, então nós não precisamos modificar o módulo),
# mas se você precisar definir você mesmo `child_spec/1` deve returnar um map de opções:

# https://hexdocs.pm/elixir/Supervisor.html#t:child_spec/0
def child_spec(opts) do
%{
  # :id => atom() | term(),
  id: SimpleQueue,
  # :start => {module(), atom(), [term()]},
  start: {__MODULE__, :start_link, [opts]},
  # optional(:restart) => :permanent | :transient | :temporary,
  restart: :permanent,
  # optional(:shutdown) => timeout() | :brutal_kill,
  shutdown: 5_000,
  # optional(:type) => :worker | :supervisor,
  type: :worker
  # optional(:modules) => [module()] | :dynamic
}
end
# child_spec(module_or_map, overrides)
  # Constrói e substitui uma especificação filho.

# Supervisor dinâmico
# Supervisores normalmente começam com uma lista de filhos para iniciar quando a aplicação inicia.
# No entanto, às vezes os filhos supervisionados não vão ser conhecidos quando a aplicação inicia
# Para casos vamos querer um supervisor que os filhos podem ser iniciados sob demanda.
# O DynamicSupervisor é usado para lidar com esses casos.
# https://hexdocs.pm/elixir/DynamicSupervisor.html#summary

# O DynamicSupervisor suporta apenas a estratégia de supervisão :one_for_one

# start_child(supervisor, child_spec)
# Adiciona dinamicamente uma especificação filho `child_spec` ao supervisor `supervisor` e inicia esse filho.
# Se a função de início do processo filho retornar {:ok, child} ou {:ok, child, info},
# então a especificação filho e o PID são adicionados ao supervisor e esta função retorna o mesmo valor.

# vamos iniciar um novo SimpleQueue dinamicamente nós vamos usar `start_child/2`
# que recebe um supervisor e a especificação do filho
# (SimpleQueue usa use GenServer então a especificação do filho já é definida)

# lib/simple_queue/application.ex
#comenta Supervisor.start_link(children, opts)
# DynamicSupervisor.start_link(opts)

iex> {:ok, pid} = DynamicSupervisor.start_child(SimpleQueue.Supervisor, SimpleQueue)
{:ok, #PID<0.152.0>}
iex> pid # se o DynamicSupervisor.start_child/2 tiver na SimpleQueue.Application
#PID<0.152.0>

# Supervisor de tarefas
# Tarefas têm o seu próprio Supervisor especializado, o Task.Supervisor.
# Projetado para tarefas criadas dinamicamente, o supervisor usa DynamicSupervisor por debaixo dos panos.
# https://hexdocs.pm/elixir/Task.Supervisor.html#summary

# lib/simple_queue/application.ex
children = [
  {Task.Supervisor, name: ExampleApp.TaskSupervisor, restart: :transient}
]

{:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

# A maior diferença entre Supervisor e Task.Supervisor é que a estratégia de reinício
# padrão é :temporary (tarefas nunca irão ser reiniciadas).

# Tarefas Supervisionadas
# Com o supervisor inicializado, podemos usar a função `start_child/2` para criar uma tarefa supervisionada:

{:ok, pid} = Task.Supervisor.start_child(ExampleApp.TaskSupervisor, fn -> background_work end)

# Se a nossa tarefa quebrar antes do tempo certo, ela irá ser reiniciada para nós.
# Isto pode ser particularmente útil quando se trabalha com conexões de entrada ou processamento em background.

# start_child(supervisor, fun, options \\ [])
  # Inicia uma tarefa como filho de determinado `supervisor`.
# start_child (supervisor, módulo, função, argumentos, opções \\ [])
  # Semelhante a start_child/2, exceto que a tarefa é especificada pelo `módulo`, `função` e `argumentos` fornecidos.
