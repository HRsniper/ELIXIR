# Erlang Term Storage, comumente referenciado como ETS, é um poderoso mecanismo de armazenamento,
# incorporado no OTP e disponível para uso no Elixir.
# Estes fornecem a capacidade de armazenar grandes quantidades de dados em um sistema de tempo de execução Erlang,
# e ter tempo de acesso constante aos dados.

# Tabelas em ETS são criadas por processos individuais. Quando um processo proprietário termina
# suas tabelas são destruídas. Por padrão ETS está limitado a 1400 tabelas por cada nó.

# Criando Tabelas
# Tabelas são criadas usando new/2, que aceita como parâmetros o nome da tabela, uma série de opções,
# e retorna um identificador de tabela que podemos usar nas operações subsequentes.

# new(Name, Options) -> tid() | atom()
# Opções de parâmetro é uma lista de opções que especifica o tipo de tabela,
# direitos de acesso, posição da chave e se a tabela é nomeada.
# [
#   set,
#   ordered_set,
#   bag
#   duplicate_bag,
#   public,
#   protected,
#   private,
#   named_table,
#   {keypos,Pos},
#   {heir,Pid,HeirData} | {heir,none},
#   {read_concurrency,boolean()},
#   {write_concurrency,boolean()},
#   {decentralized_counters,boolean()},
#   compressed
# ]

iex> table = :ets.new(:user_search, [:set, :protected])
#Reference<0.2763010273.40239106.199555>

# existe um mecanismo para acessar tabelas ETS usando nome em vez de identificador.
# precisamos incluir a opção :named_table e assim podemos acessar nossa tabela diretamente pelo nome.
iex> :ets.new(:user_search, [:set, :protected,  :named_table])
# :user_search

# Existem quatro tipos de tabelas disponíveis no ETS:
  # set — Este é o tipo de tabela padrão. Um valor para cada chave. Chaves são únicas.
  # ordered_set — Igual ao set mas ordenado por termo Erlang/Elixir.
    # É importante notar que comparação de chave é diferente dentro do ordered_set.
    # Chaves não devem coincidir desde que sejam iguais. 1 e 1.0 são considerados iguais.
  # bag — Muitos objetos por cada chave mas apenas uma instância de cada objeto por cada chave.
  # duplicate_bag — Muitos objetos por cada chave; chaves duplicadas são permitidas.

# Controle de acesso no ETS é semelhante ao controle de acesso dentro de módulos:
  # public - Leitura/Escrita disponíveis para todos os processos.
  # protected - Leitura disponível para todos os processos. Escrita disponível apenas para o proprietário. É o padrão.
  # private - Leitura/Escrita limitado ao proprietário do processo.

# Condições da corrida (race conditions)
# Se mais de um processo puder escrever em uma tabela seja via público ou por mensagens para o processo proprietário,
# condições de corrida são possíveis.
# Por exemplo, dois processos, cada um lê um valor de contador de valor 0, incrementa-o e escrevem 1;
# o resultado final reflete apenas um único incremento.
# Para contadores especificamente, :ets.update_counter/3 fornece atualização e leitura atômica.
# Para outros casos, pode ser necessário que o processo do proprietário execute operações atômicas personalizadas
# em resposta a mensagens, como “adicione este valor à lista na chave :resultados”.
update_counter(Tab, Key, Incr, Default) -> Result


# ETS não tem schema. A única limitação é que os dados devem ser armazenados como uma tupla
# cujo primeiro elemento é a chave. Para adicionar novos dados, podemos usar insert/2.
insert(Tab, ObjectOrObjects) -> true

iex> :ets.insert(:user_search, {"elixir", "v2"})
# true
iex> :ets.insert(:user_search, {"elixir", ["v1","v2"]})
# true

# Quando usamos insert/2 com um set ou ordered_set dados existentes serão substituídos.
# a fim de evitar isso, existe o insert_new/2 que retorna false se existir chaves iguais.
insert_new(Tab, ObjectOrObjects) -> boolean()

iex> :ets.insert_new(:user_search, {"elixir", ["v1","v2"]})
# false
iex> :ets.insert_new(:user_search, {"javascript", ["es20","es21"]})
# true

# Recuperando Dados
# ETS oferece-nos algumas formas convenientes e flexíveis para recuperar nossos dados armazenados.
# Iremos ver como recuperar dados usando a chave através de diferentes formas de correspondência de padrão (pattern matching).
# O mais eficiente, e ideal, método de recuperar dados é a busca por chave.
# Enquanto útil, matching percorre a tabela e deve ser usado com moderação especialmente para grandes conjuntos de dados.
lookup(Tab, Key) -> [Object]

iex> :ets.lookup(:user_search, "elixir")
# [{"elixir", ["v1", "v2"]}]


# Correspondências Simples
# ETS foi construído para o Erlang, logo tenha atenção que correspondência de variáveis
# pode parecer um pouco desajeitado. Para especificar uma variável no nosso match,
# usamos os atoms :"$1", :"$2", :"$3", e assim por diante;
# o número da variável reflete a posição do resultado e não a posição do match.
# Para valores que não nos interessam usamos a variável :_
match(Tab, Pattern) -> [Match]

iex> :ets.match(:user_search, {:"$2", "Sean"})
# [["doomspork"]]
iex> :ets.match(:user_search, {:"$1", "elixir", :_})

:ets.match(:user_search, {:"$2", :_})
# [["doomspork"], ["elixir"], ["javascript"]]

iex> :ets.match(:user_search, {:"$1", :"$2"})
# [
#   ["doomspork", "Sean"],
#   ["elixir", ["v1", "v2"]],
#   ["javascript", ["es20", "es21"]]
# ]

# Podemos usar match_object/2, que independentemente das variáveis retorna nosso objeto inteiro:
match_object(Tab, Pattern) -> [Object]

iex> :ets.match_object(:user_search, {:"$2", "Sean"})
# [{"doomspork", "Sean"}]

# Pesquisa Avançada
# Aprendemos sobre casos simples de fazer match, mas o que se quisermos algo mais parecido a uma consulta SQL?
# Felizmente existe uma sintaxe mais robusta disponível para nós. Para pesquisar nossos dados com select/2
# precisamos construir uma lista de tuplas com três aridades. Estas tuplas representam o nosso padrão,
# zero ou mais guardas, e um formato de valor de retorno.
# Nossas variáveis de correspondência e mais duas novas variáveis, :"$$" e :"$_"
# podem ser usadas para construir o valor de retorno. Estas novas variáveis são atalhos para o formato
# do resultado; :"$$" recebe resultados como listas e :"$_" o objeto do dado original.
select(Tab, MatchSpec) -> [Match]

iex> :ets.select(:user_search, [{{:"$1", :_}, [],  [:"$_"]}])
# [
#   {"doomspork", "Sean"},
#   {"elixir", ["v1", "v2"]},
#   {"javascript", ["es20", "es21"]}
# ]

# a sintaxe do select/2 é um bastante hostil e tende a ser pior.
# Para lidar com isso, o módulo ETS inclui fun2ms/1, para transformar as funções em match_specs.
# Com fun2ms/1 podemos criar consultas usando uma sintaxe de função mais familiar.
fun2ms(LiteralFun) -> MatchSpec

iex> fun = :ets.fun2ms(fn {key, _} -> key end)
# [{{:"$1", :_}, [], [:"$1"]}]
iex> :ets.select(:user_search, fun)
# ["doomspork", "elixir", "javascript"]

# Removendo Registros
# Eliminar termos é tão simples como insert/2 e lookup/2. Com delete/2 precisamos apenas da nossa tabela
# e a chave. Isso elimina tanto a chave como o seu respectivo valor.
delete(Tab, Key) -> true

iex> :ets.delete(:user_search, "doomspork")
# true

# Removendo Tabelas
# As tabelas ETS não são coletadas como lixo, a menos que o pai seja encerrado.
# Às vezes, pode ser necessário excluir uma tabela inteira sem encerrar o processo de proprietário com delete/1

iex> :ets.delete(:user_search)
# true


# vamos criar um app para exemplo
$ mix new aula38_ets_simple_cache --sup
$ cd aula38_ets_simple_cache

# em lib\aula38_ets_simple_cache.ex
# o código vai estar la por que é muito extenso

# Por enquanto a única opção em get/4, com que iremos nos preocupar é :ttl.

# Para demonstrar o uso do cache, iremos usar a função que retorna a hora do sistema e um TTL de 10 segundos.

$ iex -S mix

iex> defmodule ExampleApp do
  def test do
    :os.system_time(:seconds)
  end
end

iex> :ets.new(:simple_cache, [:named_table])
# :simple_cache
iex> ExampleApp.test
# 1624152518

iex> SimpleCache.get(ExampleApp, :test, [], ttl: 10)
# 1624152533
iex> SimpleCache.get(ExampleApp, :test, [], ttl: 10)
# 1624152550
iex> SimpleCache.get(ExampleApp, :test, [], ttl: 10)
# 1624152550
iex> SimpleCache.get(ExampleApp, :test, [], ttl: 10)
# 1624152561
# Depois de 10 segundos se não tentarmos novamente deveremos receber um novo resultado.

# somos capazes de implementar um cache escalável e rápido sem nenhuma dependência externa
# e este é apenas um dos muitos usos do ETS.

# ETS baseado em disco
# Agora sabemos que o ETS é para armazenamento de termo em memória, mas e se precisarmos de armazenamento
# baseado em disco? Para isso, temos Disk Based Term Storage, ou DETS para abreviar.
# As APIs ETS e DETS são intercambiáveis,com exceção de como as tabelas são criadas.
# DETS depende de open_file/2 e não requer a opção :named_table.
# DETS não suporta ordered_set como ETS, apenas set, bag, e duplicate_bag.
open_file(Name, Args) -> {ok, Name} | {error, Reason}

iex> {:ok, table} = :dets.open_file(:disk_storage, [type: :set])
# {:ok, :disk_storage}
iex> :dets.insert_new(table, {"doomspork", "Sean", ["Elixir", "Ruby", "Java"]})
# true
iex> :dets.insert_new(table, {"aula", "38", ["Elixir", "Ruby", "Java"]})
iex> select_all = :ets.fun2ms(&(&1))
# [{:"$1", [], [:"$1"]}]
iex> :dets.select(table, select_all)
# [
  # {"doomspork", "Sean", ["Elixir", "Ruby", "Java"]},
  # {"aula", "38", ["Elixir", "Ruby", "Java"]}
# ]

# Se sairmos do iex e olhar no seu diretório atual, terá um arquivo novo com nome de disk_storage
