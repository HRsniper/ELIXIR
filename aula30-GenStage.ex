# https://hexdocs.pm/elixir/GenEvent.html#content
# GenEvent: Este comportamento está obsoleto.

# Use o módulo `:gen_event` do Erlang/OTP.
# (https://erlang.org/doc/man/gen_event.html)

# :gen_event Um gerenciador de eventos com comportamento de manipuladores de eventos.

# GenStage
# Se o caso de uso em que você estava usando GenEvent/:gen_event exigir uma lógica mais complexa,
# o GenStage oferece uma ótima alternativa. GenStage é uma biblioteca Elixir externa mantida pela equipe Elixir;
# ele fornece uma ferramenta para implementar sistemas que trocam eventos de uma forma orientada
# pela demanda com suporte integrado para contrapressão.

# Documentação GenStage: https://hexdocs.pm/gen_stage/GenStage.html

# GenStage (behaviour)
# Estágios são etapas de troca de dados que enviam / ou recebem dados de outros estágios.
# Quando um estágio envia dados, ele atua como um produtor. Ao receber dados, ele atua como consumidor.
# Os estágios podem assumir funções de produtor e consumidor ao mesmo tempo.

# o GenStage nos fornece uma forma de definir um pipeline de trabalho a ser realizado por passos
# independentes (ou etapas) em processos separados

[A] -> [B] -> [C]
# Neste exemplo temos três etapas:
  # A um produtor (e portanto uma fonte),
  # B um produtor-consumidor,
  # C um consumidor (e portanto um coletor)

# A produz um valor que é consumido por B,
# B executa algum trabalho e retorna um novo valor que é recebido pelo nosso consumidor C;

# Um consumidor pode ter vários produtores e um produtor pode ter vários consumidores.
# Quando um consumidor pede dados, cada produtor é atendido separadamente, com sua própria demanda.
# Quando um produtor recebe demanda e envia dados para vários consumidores, a demanda é rastreada e
# os eventos são enviados por um despachante. Isso permite que os produtores enviem dados usando diferentes "estratégias".
# Consulte GenStage.Dispatcher para obter mais informações: https://hexdocs.pm/gen_stage/GenStage.Dispatcher.html

# Consumidores e Produtores
# o papel que damos à nossa etapa é importante. A especificação do GenStage reconhece três papéis:
# :producer — Uma fonte. Produtores esperam por demanda de consumidores e respondem com os eventos solicitados.
# :producer_consumer — Tanto uma fonte quanto um consumidor. Produtor-consumidores podem responder
  # por demandas de outros consumidores assim como solicitar eventos de produtores.
# :consumer — Um consumidor. Um consumidor solicita e recebe dados de produtores.

# Notou que nossos produtores esperam por demanda? Com o GenStage nossos consumidores enviam demanda
# e processam os dados de nosso produtor. Isso facilita o mecanismo conhecido como back-pressure(contrapressão).
# Back-pressure coloca a responsabilidade no produtor a não pressionar demais quando consumidores estão ocupados.

# Começando
# construiremos uma aplicação GenStage que emite números, separa os números pares, e finalmente os imprime.
# usaremos todos os três papéis do GenStage.
# Nosso produtor será responsável por contar e emitir números.
# O produtor-consumidor para filtrar somente os números pares e depois responder à demanda.
# E um consumidor para nos mostrar os números restantes.

$ mix new genstage_example --sup
$ cd genstage_example

# Vamos atualizar nossas dependências no mix.exs para incluir gen_stage:
defp deps do
  [
    {:gen_stage, "~> 1.1.0"}
  ]
end

# buscar dependências e compilar
$ mix do deps.get, compile


# criando producer
# lib/genstage_example/producer.ex
defmodule GenstageExample.Producer do
  use GenStage

  def start_link(initial \\ 0) do
    GenStage.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def init(counter), do: {:producer, counter}

  def handle_demand(demand, state) do
    events = Enum.to_list(state..(state + demand - 1))
    {:noreply, events, state + demand}
  end
end

# GenStage.start_link (módulo, args, opções \\ []) function
# Inicia um processo GenStage vinculado ao processo atual.
# Isso geralmente é usado para iniciar o GenStage como parte de uma árvore de supervisão.
# uma que o servidor é iniciado, a função init/1 do módulo fornecido é
# chamada com args como seus argumentos para inicializar o estágio.
# Esta função também aceita todas as opções aceitas por GenServer.start_link/3.

# init (args) callback
# invocado quando o servidor é iniciado.
# start_link/3 ou start/3 será bloqueado até que esse callback retorne.
# args é o termo do argumento (segundo argumento) passado para start_link/3 ou start/3.
# Em caso de início bem-sucedido, esse callback deve retornar uma tupla em que o primeiro elemento é o
# tipo de estágio, que é um dos seguintes:
# {:producer, ...}
# {:consumer, ...}
# {:producer_consumer, ...}

# handle_demand (demanda, estado) callback
# invocado em estágio de :producer.
# Este callback é invocado em estágio de :producer com a demanda dos consumidores/despachante.
# O produtor que implementa esse callback deve armazenar a demanda ou retornar a quantidade de eventos solicitados.
# Deve sempre ser explicitamente implementado em estágio de :producer
# retona {:noreply, [event], new_state}

# https://hexdocs.pm/gen_stage/GenStage.html#summary

# criando producer_consumer
# lib/genstage_example/producer_consumer.ex
defmodule GenstageExample.ProducerConsumer do
  use GenStage

  require Integer

  def start_link(_initial) do
    GenStage.start_link(__MODULE__, :state_doesnt_matter, name: __MODULE__)
  end

  def init(state) do
    {:producer_consumer, state, subscribe_to: [GenstageExample.Producer]}
  end

  def handle_events(events, _from, state) do
    numbers =
      events
      |> Enum.filter(&Integer.is_even/1)

    {:noreply, numbers, state}
  end
end

# Com a opção subscribe_to: no init/1, instruímos o GenStage a nos colocar em comunicação com um produtor específico.

# handle_events (events, from, state) callback
# Invocado nos estágios :producer_consumer e :consumer para manipular eventos.
# Sempre deve ser explicitamente implementado por esses tipos.
# Retornando {: noreply, [event], new_state} despacha os eventos e continua o loop com o novo estado new_state.
# o restante dos valores de retorno são iguais a handle_cast/2.(https://hexdocs.pm/gen_stage/GenStage.html#c:handle_events/3)

criando consumer
# lib/genstage_example/consumer.ex
defmodule GenstageExample.Consumer do
  use GenStage

  def start_link(_initial) do
    GenStage.start_link(__MODULE__, :state_doesnt_matter)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [GenstageExample.ProducerConsumer]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      IO.inspect({self(), event, state})
    end

    # Como consumidores, nunca emitimos eventos
    {:noreply, [], state}
  end
end

# nosso consumidor não emite eventos, então o segundo valor em nossa tupla será descartado.


# Colocando tudo junto
# Agora que temos nosso produtor, produtor-consumidor, e consumidor construídos, estamos prontos para ligá-los todos juntos.

# vamos adicionar nossos novos processo para a árvore de supervisores
# lib/genstage_example/application.ex
  children = [
    {GenstageExample.Producer, 0},
    {GenstageExample.ProducerConsumer, []},
    {GenstageExample.Consumer, []}
  ]

# Se tudo estiver certo, podemos executar nosso projeto e devemos ver tudo funcionando:
$ mix run --no-halt
# {#PID<0.109.0>, 1, :state_doesnt_matter}
# {#PID<0.109.0>, 2, :state_doesnt_matter}
# ...
# {#PID<0.198.0>, 351632, :state_doesnt_matter}
# {#PID<0.198.0>, 351634, :state_doesnt_matter}


# Múltiplos Produtores ou Consumidores
# Se examinarmos a saída do IO.inspect/1 do nosso exemplo, vemos que todo evento é tratado por um único PID

# lib/genstage_example/application.ex
children = [
  {GenstageExample.Producer, 0},
  {GenstageExample.ProducerConsumer, []},
  %{
    id: 1,
    start: {GenstageExample.Consumer, :start_link, [[]]}
  },
  %{
    id: 2,
    start: {GenstageExample.Consumer, :start_link, [[]]}
  },
]

# configuramos dois consumidores, agora obtemos 2 pid diferentes se rodarmos nossa aplicação agora

$ mix run --no-halt
# {#PID<0.165.0>, 0, :state_doesnt_matter}
# {#PID<0.166.0>, 1500, :state_doesnt_matter}
# {#PID<0.165.0>, 2, :state_doesnt_matter}
# {#PID<0.166.0>, 1502, :state_doesnt_matter}
# {#PID<0.165.0>, 4, :state_doesnt_matter}
# ...
# {#PID<0.165.0>, 4016, :state_doesnt_matter}
# {#PID<0.166.0>, 5016, :state_doesnt_matter}
# {#PID<0.165.0>, 4018, :state_doesnt_matter}
# {#PID<0.166.0>, 5018, :state_doesnt_matter}


# Casos de Uso
# Agora que cobrimos o GenStage e construímos nosso primeiro aplicativo de exemplo,
# quais são alguns dos casos de uso reais do GenStage?

# Pipeline de transformação de dados - os produtores não precisam ser simples geradores de números.
# Poderíamos produzir eventos a partir de um banco de dados ou até mesmo de outra fonte como o Apache Kafka.
# Com uma combinação de produtores-consumidores e consumidores, podemos processar, classificar, catalogar
# e armazenar as métricas à medida que se tornam disponíveis.

# Fila de trabalho - Como os eventos podem ser qualquer coisa, poderíamos produzir unidades de trabalho
# a serem concluídas por uma série de consumidores.

# Processamento de eventos - Semelhante a um pipeline de dados, podemos receber, processar, classificar
# e executar ações em eventos emitidos em tempo real de nossas fontes.

# Estas são apenas algumas das possibilidades do GenStage.
