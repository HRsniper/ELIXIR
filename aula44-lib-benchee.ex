
# Não podemos simplesmente adivinhar quais funções são rápidas e quais são lentas,
# precisamos de medidas reais quando estamos curiosos. É aí que benchmarking entra.
# O Benchee permite comparar o desempenho de diferentes partes do código em um relance.

# existe uma função no Erlang a 'tc/3, tc/2, tc/1' que pode ser usada para medição muito básica do tempo
# de execução de uma função, ela não é tão boa de usar como algumas das ferramentas disponíveis
# e não lhe dá várias medidas para obter boas estatísticas, então vamos usar Benchee.

$ mix new aula44_benchee

# em mix.exs
defp deps do
  [
    {:benchee, "~> 1.0", only: :dev}
  ]
end

$ mix do deps.get, compile

# Uma nota importante antes de começarmos: Quando avaliar comparativamente,
# é muito importante não usar iex uma vez que isso funciona de forma diferente
# e é frequentemente muito mais lento do que seu código usado em produção.
# Então, vamos criar um arquivo que chamaremos benchmark.exs.

# em lib\benchmark.exs
list = Enum.to_list(1..10_000)
map_fun = fn i -> [i, i * i] end

Benchee.run(
  %{
    "flat_map" => fn -> Enum.flat_map(list, map_fun) end,
    "map.flatten" => fn -> list |> Enum.map(map_fun) |> List.flatten() end
  }
)

# Agora para executar nosso benchmark
$ mix run lib/benchmark.exs
# Operating System: Windows
# CPU Information: Pentium(R) Dual-Core  CPU      E5500  @ 2.80GHz
# Number of Available Cores: 2
# Available memory: 3.50 GB
# Elixir 1.12.1
# Erlang 22.3

# Benchmark suite executing with the following configuration:
# warmup: 2 s
# time: 5 s
# memory time: 0 ns
# parallel: 1
# inputs: none specified
# Estimated total run time: 14 s

# Benchmarking flat_map...
# Benchmarking map.flatten...

# Name                  ips        average  deviation         median         99th %
# flat_map           227.27        4.40 ms    +32.52%        4.70 ms        9.40 ms
# map.flatten        206.00        4.85 ms    +33.67%        4.70 ms       12.38 ms

# Comparison:
# flat_map           227.27
# map.flatten        206.00 - 1.10x slower +0.45 ms

# É claro que as informações e os resultados do seu sistema podem ser diferentes dependendo das especificações
# da máquina em que você está executando seus benchmarks.
# Na seção Comparison nos mostra que a versão do nosso 'map.flatten' é 1.10x mais lenta do que 'flat_map'.
# E também mostra que, em média, é cerca de 0.45 microssegundos mais lento,
# o que coloca as coisas em perspectiva. Isso é útil saber!

# vamos olhar para as outras estatísticas que temos:
  # ips - isso significa “iterações por segundo”, que nos diz com que frequência a função pode ser executada
  #   em um segundo. Para esta métrica, um número maior é melhor.
  # average - este é o tempo médio de execução da função. Para esta métrica, um número baixo é melhor.
  # deviation - este é o desvio padrão, que nos diz o quanto os resultados para cada iteração
  #   variam nos resultados. Aqui é dado como uma porcentagem da média.
  # median - quando todos tempos medidos são ordenados, este é o valor médio
  #   (ou média dos dois valores do meio quando o número de amostras é par).
  #   Devido à inconsistências de ambiente este será mais estável do que a average, e um pouco mais provável
  #   que reflita a performance normal do seu código em produção. Para esta métrica, um número baixo é melhor.
  # 99th% - 99% de todas as medições são mais rápidas do que isto, o que torna este tipo como pior
  # caso de desempenho. Menor é melhor.

# Há também outras estatísticas disponíveis, mas estas quatro são frequentemente as mais úteis
# e comumente usadas para benchmarking, por isso elas são exibidas no formatador padrão.
# Para aprender mais sobre outras métricas disponíveis, confira a documentação (https://hexdocs.pm/benchee/Benchee.Statistics.html#t:t/0).

# Configuração
# Uma das melhores partes do Benchee são todas as opções de configuração disponíveis.
# Examinaremos o básico primeiro, uma vez que não requerem exemplos de código,
# e então mostraremos como usar uma das melhores características do Benchee - inputs.

# O Benchee oferece uma grande variedade de opções de configuração, mas essas são totalmente opcionais.
# Benchee vem com padrões razoáveis para todos esses.
# Na interface mais comum 'Benchee.run/2', as opções de configuração são passadas
# como o segundo argumento na forma de uma lista de palavras-chave.
run(jobs, config \\ [])


# exemplo
Benchee.run(%{"example function" => fn -> "hi!" end}, [
    warmup: 2,
    time: 5,
    memory_time: 0,
    inputs: nil,
    title: "title",
    formatters: [Benchee.Formatters.Console],
    pre_check: false,
    parallel: 1,
    save: [path: "save.benchee", tag: "first-try"],
    load: "save.benchee",
    print: [
      benchmarking: true,
      configuration: true,
      fast_warning: true
    ],
    console: [
      comparison: true,
      extended_statistics: true
    ],
    percentiles: [50, 99],
    unit_scaling: :best,
    measure_function_call_overhead: true,
    before_scenario: fn input -> ... end,
    after_scenario: fn _input -> bust_my_cache() end,
    before_each: fn input -> get_from_db(input) end,
    after_each: fn result -> assert result == 42 end
  ]
)

# warmup - o tempo em segundos durante o qual um trabalho de benchmarking deve ser executado
#  sem medir os tempos antes do início das medições "reais".
#  Isso simula um sistema de funcionamento "quente". O padrão é 2.
# time - o tempo em segundos por quanto tempo cada cenário individual (trabalho de benchmarking x entrada)
#  deve ser executado para medir os tempos de execução (desempenho do tempo de execução). O padrão é 5.
# memory_time - o tempo em segundos por quanto tempo as medições de memória devem ser realizadas. O padrão é 0 (desligado).
# inputs  -  um mapa com strings que representam o nome da entrada como as chaves e a entrada real como os valores.
#  O padrão é nil, sem nenhuma entrada especificada e as funções são chamadas sem um argumento.
# title - esta opção é puramente cosmética. Se desejar adicionar um título com algum significado
#  a um determinado conjunto, você pode fazer isso fornecendo uma única string aqui. Isso deve ser usado apenas por formatadores.
# formatters - lista de formatadores como um módulo que implementa o comportamento do formatador,
#  uma tupla do referido módulo e opções que ele deve assumir ou funções do formatador.
#  Eles são executados ao usar Benchee.run/2 ou você pode invocá-los por meio de Benchee.Formatter.output/1.
#  O padrão é o formatador de console integrado Benchee.Formatters.Console.
# pre_check - se deve ou não executar cada trabalho com cada entrada,
#  incluindo todos os cenários fornecidos antes ou depois ou cada hook,
#  antes que os benchmarks sejam medidos para garantir que seu código seja executado sem erros.
#  Isso pode economizar tempo durante o desenvolvimento de suas suítes. O padrão é false.
# parallel - cada função de cada trabalho será executada em processos paralelos.
#  Se 'parallel: 4', 4 processos serão gerados, todos executando a mesma função durante o tempo determinado ':time'.
#  Quando estes terminarem/ou tempo acabar, 4 novos processos serão gerados para o próximo trabalho/função.
#  Isso fornece mais dados ao mesmo tempo, mas também sobrecarrega o sistema, interferindo nos resultados
#  do benchmark. O padrão é 1 (sem execução paralela).
# save - especifique uma lista com ':path' onde armazenar os resultados do pacote de benchmarking atual,
#  marcado com a ':tag' especificada.
# load - carregue suit ou suits salvos para comparar seus benchmarks atuais.
#  Pode ser uma string "" ou uma lista de strings ["",""] ou patterns "name*.benchee".
# print - um mapa de átomos com valo de true ou false para configurar se a saída identificada pelo átomo será impressa.
#   Todas as opções são ativadas como true por padrão.
#   As opções são:
#     :benchmarking - imprime quando Benchee começa a fazer o benchmarking de um novo trabalho (nome do Benchmarking ..)
#     :configuração - um resumo das opções de benchmarking configuradas, incluindo o tempo total estimado
#       de execução, é impresso antes do início do benchmarking.
#     :fast_warning - avisos são exibidos se as funções forem executadas muito rápido, levando a medidas imprecisas.
# console - opções para o formatador de console integrado.
#   :comparison - se a comparação dos diferentes trabalhos de benchmarking (x vezes mais lento que)
#     for mostrada (true/false). Ativado por padrão.
#   :extended_statistics - exibe mais estatísticas, também conhecidas como 'minimum', 'maximum', 'sample_size'
#     e 'mode'. Desativado por padrão.
# percentiles - se você estiver usando estatísticas estendidas e quiser ver os resultados
#   de determinados percentis de resultados além da mediana. O padrão é [50, 99]
#   para calcular o 50th e o 99th percentis.
# :unit_scaling - a estratégia para escolher uma unidade para durações e contagens.
#   Pode ou não ser implementado por um determinado formatador (O formatador do console o implementa).
#   Ao dimensionar um valor, Benchee encontra a unidade de "melhor ajuste"
#   (a maior unidade para a qual o resultado é pelo menos 1).
#   Por exemplo, '1_200_000' escala para '1,2 M', enquanto '800_000' escala para '800 K'.
#   A estratégia de escala unitária determina como Benchee escolhe a unidade de melhor
#   ajuste para uma lista inteira de valores, quando os valores individuais na lista podem
#   ter diferentes unidades de melhor ajuste.
#   Existem quatro estratégias, o padrão é ':best'
#     :best - a unidade de melhor ajuste mais frequente será usada, um empate resultará na seleção da unidade maior.
#     :largest - a maior unidade de melhor ajuste será usada (ou seja, mil e segundos se os valores forem grandes o suficiente).
#     :smallest - a menor unidade de melhor ajuste será usada (ou seja, milissegundo e um)
#     :none - nenhuma escala de unidade ocorrerá. As durações serão exibidas em microssegundos
#       e as contagens serão exibidas em unidades.
# :measure_function_call_overhead - Mede quanto tempo leva uma chamada de função vazia
#   e deduz isso de cada tempo de execução de medida. O padrão é true.
# :before_scenario - É executado antes de cada cenário a que se aplica.
# :after_scenario - É executado depois que um cenário é concluído.
# :before_each - É executado antes de cada invocação da função de benchmarking (antes de cada medição).
# :after_each - É executado logo após a invocação da função de benchmarking.

Inputs
