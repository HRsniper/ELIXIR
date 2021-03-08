# Podemos executar nossas aplicações Elixir em um conjunto diferente de nós de processamento (nodes),
# e distribuídos em um único servidor ou entre múltiplos servidores.
# Elixir permite que nos comuniquemos entre esses nós de processamento por meio de alguns mecanismos diferentes.

# Comunicação Entre Nós de Processamento
# Elixir roda em uma VM Erlang, o que significa que tem acesso à poderosa
# funcionalidade de distribuição do Erlang.http://erlang.org/doc/reference_manual/distributed.html
  # Um sistema Erlang distribuído consiste em vários sistemas Erlang em execução se comunicando uns com os outros.
  # Cada sistema em execução é chamado de nó de processamento

# Um nó de processamento é qualquer sistema Erlang em execução que possua um nome.
# usando o sinalizador de linha de comando -name (nomes longos) ou -sname (nomes curtos).
# O formato do nome do nó é um átomo
# Um nó com um nome de nó longo não pode se comunicar com um nó com um nome de nó curto.
# Podemos iniciar um nó de processamento abrindo uma sessão `iex` e nomeando-a:

$ iex --sname hr@localhost
iex(hr@localhost)1>

# Enviando Mensagens
# se abrirmos outro node com outro nome esses dois nós de processamento podem enviar mensagens entre si usando `Node.spawn_link/2`
# https://hexdocs.pm/elixir/Node.html#summary

# spawn_link (nó, função)
  # Retorna o PID de um novo processo vinculado iniciado pela aplicação de `função` no `nó`.
# spawn_link (nó, módulo, função, argumentos)
  # Retorna o PID de um novo processo vinculado iniciado pela aplicação de `module`.`function`(`argumentos`) no `nó`.

# Essas função recebe dois argumentos:
# O nome do nó de processamento ao qual você deseja se conectar
# A função a ser executada pelo processo remoto em execução no outro nó de processamento
# Isso estabelece a conexão com o nó de processamento remoto e executa a função enviada para aquele nó, retornando o PID dos processos conectados.

# Vamos definir um módulo, Kate, em um nó de processamento chamado kate que sabe como apresentar Kate, a pessoa:
iex(kate@localhost)> defmodule Kate do
                       def say_name do
                         IO.puts "Hi, my name is Kate"
                       end
                     end

# em outro node
iex(hr@localhost)> Node.spawn_link(:kate@localhost, fn -> Kate.say_name end)
# Hi, my name is Kate
#PID<13816.121.0>

# A VM Erlang gerencia I/O (E/S - Entrada/Saída) por meio de processos.
# Isso permite que executemos tarefas de I/O, como IO.puts, entre nós de processamento distribuídos
# O líder do grupo sempre é o nó de processamento que gerou os processos.
# Então hr@localhost é o node do qual chamamos spawn_link/2, esse nó é o líder do grupo e a saída de IO.puts
# será direcionada para o fluxo de saída desse nó.

# Respondendo a Mensagens
# E se quisermos que o nó de processamento que recebe a mensagem envie alguma resposta de volta ao remetente?
# Nós podemos usar uma configuração simples de `receive/1` e `send/3` para fazer exatamente isso.

iex(hr@localhost)> pid = Node.spawn_link :kate@localhost, fn ->
  receive do
    {:hi, leader_node_pid} -> send leader_node_pid, :sup?
  end
end

node hr@localhost criando um link para o node kate@localhost e enviando ao node kate@localhost uma função anônima para executar.
Essa função anônima estará esperando receber uma tupla {:hi, leader_node_pid}, que descreve uma mensagem e
o PID do node hr@localhost.

iex(hr@localhost)> pid
#PID<13816.122.0>

E responderá a essa mensagem enviando de volta (via send) uma mensagem para o PID do node hr@localhost:

# self() Retorna o nó atual.
iex(hr@localhost)> send(pid, {:hi, self()})
# {:hi, #PID<0.107.0>}

iex(hr@localhost)> flush()
# :sup?
# :ok

# Comunicação entre Nós de Processamento de Diferentes Redes
# para enviar mensagens entre nós de processamento de diferentes redes,
# precisamos iniciar os nós de processamento nomeados com um cookie compartilhado:
# iex --sname node1@localhost --cookie secret_token
# iex --sname node2@localhost --cookie secret_token
# Somente nós de processamento iniciados com o mesmo cookie vão ser capazes de se conectar entre si com sucesso.


# Tarefas distribuídas
# permitem que geremos tarefas supervisionadas entre nós de processamento.
# ao trabalhar com tarefas distribuídas, deve-se usar a `Task.Supervisor.async/4` que espera módulo,
# função e argumentos explícitos, em vez de `Task.Supervisor.async/2` que trabalhar com funções anônimas.
# Isso ocorre porque as funções anônimas esperam que a mesma versão do módulo exista em todos os nós envolvidos.

# nova aplicação com  tarefas supervisionadas
$ mix new a25_chat --sup

# Uma Tarefa de Supervisão, supervisona dinamicamente tarefas. Ela é iniciada sem filhos,
# normalmente sob um supervisor próprio, e podemos usar depois para supervisionar qualquer número de tarefas.

children = [
  {Task.Supervisor, name: A25Chat.TaskSupervisor}
]

# Agora quando nossa aplicação é iniciada em determinado node, o A25Chat.Supervisor
# vai estar rodando e pronto para supervisionar tarefas.

# Enviando Mensagens com Tarefas de Supervisão
# Vamos iniciar tarefas de supervisão com a função Task.Supervisor.async/5.

# async(supervisor, module, func, args, options \\ [])
# supervisor que queremos usar para supervisionar a tarefa.Isso pode ser passado como uma tupla
  # {SupervisorName, remote_node_name} para supervisionar a tarefa em um node remoto.
# module no qual queremos executar uma função
# :função que queremos executar
# Qualquer [argumento] que precise ser fornecido para essa função
# Opções :shutdown - :brutal_kill se as tarefas devem ser eliminadas diretamente no desligamento
                  #  ou um número inteiro indicando o valor de tempo limite, o padrão é 5000 milissegundo

# Nossa aplicação de Chat é super simples. Ela envia mensagens a nodes remotos e os nodes remotos responde
# a essas mensagens, passando-as para a função IO.puts, que será exibida no console do node remoto.

# lib/a25_chat.ex dentro do modulo
  def receive_message(message) do
    IO.puts message
  end

# agora a funcao de enviar a mensagem para o node remoto usando uma tarefa supervisionada.
# lib/a25_chat.ex dentro do modulo
def send_message(recipient, message) do
  spawn_task(__MODULE__, :receive_message, recipient, [message])
end

def spawn_task(module, fun, recipient, args) do
  recipient
  |> remote_supervisor()
  |> Task.Supervisor.async(module, fun, args)
  |> Task.await()
end

defp remote_supervisor(recipient) do
  {Chat.TaskSupervisor, recipient}
end

$ cd a25_chat/
# abra em 2 shells
iex --sname node1@localhost -S mix
iex --sname node2@localhost -S mix

iex(node1@localhost)> A25Chat.send_message(:node2@localhost, "hi")
# :ok
#  no outro shell vai aparecer
iex(node2@localhost)> hi
#  O node2 pode responder de volta
iex(node2@localhost)> A25Chat.send_message(:node2@localhost, "hi, it's hi in english right, wait i'm also speaking english '-'")
# :ok
# E a mensagem aparecerá na sessão iex do node1
iex(node1@localhost)> hi, it's hi in english right, wait i'm also speaking english '-'

# send_message/2 recebe o nome do nó de processamento remoto no qual queremos executar nossas tarefas supervisionadas
  # e a mensagem que queremos enviar para esse node.
# Estamos dizendo para A25Chat.TaskSupervisor para supervisionar uma tarefa que executa
  # a função receive_message/1 que recebe como um argumento qualquer mensagem passada para
  # spawn_task/4 a partir da função send_message/2.
# Então, A25Chat.receive_message("hi") é chamada no outro node remoto.
  # isso faz com que a mensagem "hi" seja colocada no console desse nó

# Respondendo a Mensagens de Nós de Processamento Remotos
# Vamos definir outra versão da nossa função send_message/2 cujo padrão casará com o
# argumento `recipient` (pattern matching). Se o destinatário é :bigdog@locahost
# bigdog so sabe responder gyūniku

# send_message/2 pega o nome do node atual com Node.self()
# Passe o nome node atual para o remetente, para a nova função receive_message_for_bigdog/2,
# para que possamos enviar uma mensagem de volta para esse nó.

# lib/a25_chat.ex dento do modulo
def send_message(:bigdog@localhost, message) do
  spawn_task(__MODULE__, :receive_message_for_bigdog, :bigdog@localhost, [message, Node.self()])
end

# que exibe a mensagem recebida no console do nó bigdog e envia uma mensagem de volta para o remetente
def receive_message_for_bigdog(message, from) do
  IO.puts(message)
  send_message(from, "gyūniku?")
end

# mais um shell
iex --sname bigdog@localhost -S mix

iex(node1@localhost)> A25Chat.send_message(:bigdog@localhost, "hi")
# gyuniku?
# :ok

# Podemos ver que o node1 recebeu a resposta gyuniku?.
# Se abrirmos o node2, vamos ver que nenhuma mensagem foi recebida uma vez que nem node1 ou ou bigdog enviaram uma mensagem

# olhando shell do bigdog vamos ver a mensagem do node1
iex(bigdog@localhost)> hi

# Testando Código Distribuído
# \test\a25_chat_test.exs dentro do modulo de teste
test "send_message/2" do
  assert A25Chat.send_message(:bigdog@localhost, "hi") == :ok
end

$ iex --sname node1@localhost -S mix test

# Excluindo Testes Condicionalmente com Tags
# Nós vamos adicionar uma tag `ExUnit` no teste:
# O contexto é usado para passar informações dos callbacks para o teste.
# Para passar informações do teste para o callback, a ExUnit fornece tags.
# Observe que uma tag pode ser definida de duas maneiras diferentes:
  @tag key: value
  @tag :key       # equivalent to setting @tag key: true
# Se uma tag for fornecida mais de uma vez, o último valor vence.

# \test\a25_chat_test.exs dentro do modulo de teste,encima do test
@tag :distributed

# E vamos adicionar alguma lógica condicional ao nosso helper de teste para excluir testes com tais tags
# se os testes não estão executando em um node nomeado.
# \test\test_helper.exs
exclude = if Node.alive?(), do: [], else: [distributed: true]

ExUnit.start(exclude: exclude)

# Checamos se o nó está ativo com Node.alive?. Se não `else`, podemos dizer a ExUnit para pular qualquer teste
# com a tag distributed: true. Caso contrário, diremos para não excluir nenhum teste.

$ mix test
# Excluding tags: [distributed: true]
# Finished in 0.03 seconds
# 1 test, 0 failures, 1 excluded

$ iex --sname node1@localhost -S mix test
# gyuniku?
# Finished in 0.1 seconds
# 1 test, 0 failures

# Configuração da Aplicação Específicas por Ambiente
# lib\a25_chat.ex
# Vamos tornar a função `remote_supervisor/1` configurável com base no ambiente.
# Se for um ambiente de desenvolvimento, ela retornará {A25Chat.TaskSupervisor, recipient}
# e no ambiente de teste, retornará A25Chat.TaskSupervisor.

# {A25Chat.TaskSupervisor, recipient} iniciará o supervisor recebido no nó remoto fornecido.
# A25Chat.TaskSupervisor esse supervisor será usado para supervisionar a tarefa localmente.

# dentro da pasta do projeto
# Crie um arquivo, config/dev.exs, e adicione:
use Mix.Config
config :a25_chat, remote_supervisor: fn(recipient) ->
    {A25Chat.TaskSupervisor, recipient}
  end
# Crie um arquivo, config/test.exs e adicione:
use Mix.Config
config :a25_chat, remote_supervisor: fn(_recipient) ->
    A25Chat.TaskSupervisor
  end

# Crie um arquivo, config/config.exs e adicione,
# se ja tiver lembre-se de descomentar essas linhas no arquivo config/config.exs:
use Mix.Config

import_config "#{Mix.env()}.exs"
# https://hexdocs.pm/elixir/Config.html#import_config/1


# agora podemos atualizar nossa função `A25Chat.remote_supervisor/1` para pesquisar
# e usar a função armazenada em uma variável da nossa aplicação.
# lib/a25_chat.ex dento do modulo
defp remote_supervisor(recipient) do
  Application.get_env(:chat, :remote_supervisor).(recipient)
end

$ iex --sname node1@localhost -S mix test
# hi
# gyuniku?
# Finished in 0.04 seconds
# 1 test, 0 failures

# em `dev` continuo como estava antes
