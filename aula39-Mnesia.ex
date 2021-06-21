# Mnesia é um sistema de banco de dados (DBMS) que vem acompanhado da Runtime do Erlang,
# e por isso podemos utilizar naturalmente com Elixir. O modelo de dados híbrido relacional
# e de objeto do Mnesia é o que o torna adequado para o desenvolvimento de aplicações distribuídas
# de qualquer escala.

# Como Mnesia faz parte do núcleo do Erlang, ao invés de Elixir, temos que acessá-lo com a sintaxe
# de dois pontos Erlang Interoperability

# Cria um novo banco de dados no disco. Vários arquivos são criados no diretório Mnesia local de cada nó.
# Observe que o diretório deve ser exclusivo para cada nó. Dois nós nunca devem compartilhar o mesmo diretório.
# Se possível, use um dispositivo de disco local para melhorar o desempenho.
create_schema(Ns :: [node()]) -> result()

iex> :mnesia.create_schema([node()])
# :ok

# ou se preferir um sintaxe do Elixir ..
iex> alias :mnesia, as: Mnesia
iex> Mnesia.create_schema([node()])
# :ok

# estamos inicializando um novo schema vazio que precisa de uma lista de nós.
# estamos passando o nó associado com a nossa sessão IEx.

# Nos
# Uma vez que executar o comando :mnesia.create_schema([node()]) via IEx,
# você deve ver uma pasta chamada Mnesia.nonode@nohost ou similar no seu diretório de trabalho atual.

# podemos nomear nossos nos com --name e --sname. Um nó é apenas uma Máquina Virtual do Erlang
# lidando com suas próprias comunicações, garbage collection, processamento agendado, memória e muito mais.
# O nó está sendo nomeado como nonode@nohost simplesmente por padrão.
$ iex --name hr@dev.com
# agora temos um no com nome que demos no --name
iex(hr@dev.com)>

# se executarmos :mnesia.create_schema([node()]), iremos ver que ele criou uma outra pasta chamada
# Mnesia.hr@dev.com.
iex(hr@dev.com)> :mnesia.create_schema([node()])
# :ok
# O propósito disto é bem simples. Nós em Erlang são usados para conectar a outros nós para compartilhar
# (distribuir) informação e recursos. Isto não tem que estar limitado a mesma máquina e pode comunicar
# através de LAN, internet, etc.

# iniciaando o Mnesia DBMS
iex(hr@dev.com)> :nnesia.start()
# :ok

# A inicialização do Mnesia é assíncrona. A chamada de função :mnesia.start() retorna o átomo :ok
# e então começa a inicializar as diferentes tabelas.
# Dependendo do tamanho do banco de dados, isso pode levar algum tempo e o programador do aplicativo
# deve aguardar as tabelas de que o aplicativo precisa antes de poderem ser usadas.
# Isso é feito usando a função :mnesia.wait_for_tables/2.
# quando executamos um sistema distribuído com dois ou mais nós participando, a função :mnesia.start/1
# deve ser executada em todos os nós participantes.
start() -> result()

# Criando Tabelas
# A função :mnesia.create_table/2 é usada para criar tabelas dentro do nosso banco de dados.
create_table(Name :: table(), Arg :: [create_option()]) -> t_result(ok)
# as opções
# [
#   {access_mode, Atom},
#   {attributes, AtomList},
#   {disc_copies, Nodelist},
#   {disc_only_copies, Nodelist},
#   {index, Intlist},
#   {load_order, Integer},
#   {majority, Flag},
#   {ram_copies, Nodelist},
#   {record_name, Name},
#   {snmp, SnmpStruct},
#   {storage_properties, [{Backend, Properties}],
#   {type, Type},
#   {local_content, Bool}
# ]

iex(hr@dev.com)> :mnesia.create_table(Person, [attributes: [:id, :name, :job]])
# {:atomic, :ok}
# Nós definimos as colunas usando os átomos :id, :name, e :job.
# O primeiro átomo :id é a chave primária. Pelo menos um atributo adicional é necessário.
# :mnesia.create_table/2 ira retornar:
  # {:atomic, :ok} se a função foi executada com êxito
  # {:aborted, Reason} se a função falhou
  # {:already_exists, Table} se a tabela já existir a razão será na forma

# Primeiro de tudo, vamos olhar para a maneira suja de leitura e escrita em uma tabela no Mnesia.
# Isso geralmente deve ser evitado, pois o sucesso não é garantido
dirty_write(Record :: tuple()) -> ok

iex(hr@dev.com)> :mnesia.dirty_write({Person, 1, "Dado 1 ", "Principal"})
# :ok
iex(hr@dev.com)> :mnesia.dirty_write({Person, 2, "Dado 2 ", "Safety Inspector"})
# :ok
iex(hr@dev.com)> :mnesia.dirty_write({Person, 3, "Dado 3 ", "Bartender"})
# :ok

# e recuperamos as entradas usamos :mnesia.dirty_read/1
dirty_read(Oid :: {Tab :: table(), Key :: term()}) -> [tuple()]

iex(hr@dev.com)> :mnesia.dirty_read({Person, 1})
# [{Person, 1, "Dado 1 ", "Principal"}]
iex(hr@dev.com)> :mnesia.dirty_read({Person, 2})
# [{Person, 2, "Dado 2 ", "Safety Inspector"}]
iex(hr@dev.com)> :mnesia.dirty_read({Person, 3})
# [{Person, 3, "Dado 3 ", "Bartender"}]
iex(hr@dev.com)> :mnesia.dirty_read({Person, 4})
# []
# Se nós tentarmos consultar um registro que não existe, Mnesia irá responder com uma lista vazia.

# Transações
# Tradicionalmente usamos transações para encapsular nossas leituras no nosso banco de dados.
# Transações são uma parte importante para concepção de sistemas altamente distribuídos e tolerantes a falhas.

# Executa o objeto funcional com argumentos como uma transação.
transaction(Fun) -> t_result(Res)

# Grava o registro na tabela
write(Record :: tuple()) -> ok

iex(hr@dev.com)> data_to_write = fn ->
  :mnesia.write({Person, 4, "Dado 4", "home maker"})
  :mnesia.write({Person, 5, "Dado 5", "unknown"})
  :mnesia.write({Person, 6, "Dado 6", "Businessman"})
  :mnesia.write({Person, 7, "Dado 7", "Executive assistant"})
end
#Function<21.126501267/0 in :erl_eval.expr/5>

iex(hr@dev.com)> :mnesia.transaction(data_to_write)
# {:atomic, :ok}
# Com base na mensagem da transação, podemos seguramente assumir
# que nós escrevemos os dados para a nossa tabela Person.

# Lê todos os registros da tabela com a chave.
read(Oid :: {Tab :: table(), Key :: term()}) -> [tuple()]

iex(hr@dev.com)> data_to_read = fn ->
  :mnesia.read({Person, 6})
end
#Function<21.126501267/0 in :erl_eval.expr/5>

iex(hr@dev.com)> :mnesia.transaction(data_to_read)
# {:atomic, [{Person, 6, "Dado 6", "Businessman"}]}

# se quiser atualizar dados, somente precisa chamar :mnesia.write/1 com a mesma chave de um registro existente.
iex(hr@dev.com)> :mnesia.transaction(
  fn ->
    :mnesia.write({Person, 5, "Dado 555", "Ex-Mayor"})
  end
)
# {:atomic, :ok}

iex(hr@dev.com)> :mnesia.transaction(
  fn ->
    :mnesia.read({Person, 5})
  end
)
# {:atomic, [{Person, 5, "Dado 555", "Ex-Mayor"}]}

# Usando Indices
# Mnesia suporta índices em colunas não-chave e dado  podem ser consultados em relação a esses índices.
# Portanto, podemos adicionar um índice à coluna :job da tabela Person.
# O resultado de retorno é similar ao :mnesia.create_table/2.
add_table_index(Tab, I) -> t_result(ok)

iex(hr@dev.com)> :mnesia.add_table_index(Person, :job)
# {:atomic, :ok}

# Uma vez que o índice tenha sido criado com sucesso, nós podemos usá-lo para buscar uma lista
# de todos os que tenha o :job igual a "Principal".
iex(hr@dev.com)> :mnesia.transaction(
  fn ->
    :mnesia.index_read(Person, "Principal", :job)
  end
)
# {:atomic, [{Person, 1, "Dado 1 ", "Principal"}]}

# Combinação e seleção
# O Mnesia oferece suporte a consultas complexas para recuperar dados de uma tabela na forma de correspondência
# e funções de seleção ad-hoc.

# A função :mnesia.match_object/1 retorna todos os registros que combinem com o padrão informado.
# Se qualquer coluna na tabela tiver índices, estes podem ser usados para tornar a busca mais eficiente.
# Use o átomo especial :_ para identificar colunas que não devem participar da combinação.
match_object(Pattern :: tuple()) -> [Record :: tuple()]

# iremos podemos buscar uma lista de todos os que tenha o :name igual a "Dado 7".
iex(hr@dev.com)> :mnesia.transaction(
  fn ->
    :mnesia.match_object({Person, :_, "Dado 7", :_})
  end
)
# {:atomic, [{Person, 7, "Dado 7", "Executive assistant"}]}

# A função :mnesia.select/2 permite que você especifique uma consulta customizada usando qualquer operador
# ou função da linguagem Elixir ou Erlang.
select(Tab, Spec) -> [Match]

iex(hr@dev.com)> :mnesia.transaction(
  fn ->
    :mnesia.select(Person, [{{Person, :"$1", :"$2", :"$3"}, [{:>, :"$1", 3}], [:"$$"]}])
  end
)
# {
#   :atomic,
#   [
#     [7, "Dado 7", "Executive assistant"],
#     [4, "Dado 4", "home maker"],
#     [6, "Dado 6", "Businessman"],
#     [5, "Dado 555", "Ex-Mayor"]
#   ]
# }

# Em suas formas mais simples, o match_spec tem a seguinte aparência
  # MatchSpec = [MatchFunction]
  # MatchFunction = {MatchHead, [Guard], [Result]}
  # MatchHead = tuple() | record()
  # Guard = {"Guardtest name", ...}
  # Result = "Term construct"

# O primeiro atributo é a tabela Person o segundo atributo
# é um triplo da forma {match, [guard], [result]}.
{
  {Person, :"$1", :"$2", :"$3"}, # match é o mesmo que você passaria para a função :mnesia.match_object/1
  [{:>, :"$1", 3}], # guard é uma lista de tuplas que especifica quais funções de guarda aplicar,
                    # neste caso a função integrada :> (maior que) com o primeiro parâmetro,
                    # o posicional :"$1" e a constante 3 como atributos.
  [:"$$"] # result é a lista de campos que serão retornados pela consulta,
          # na forma de parâmetros posicionais do átomo especial :"$$" para referenciar todos os campos.
}
# :"$$" recebe resultados como listas e :"$_" o objeto do dado original.


# vamos usar uma função do ets para fazer o nosso match_spec
iex(hr@dev.com)> fun = :ets.fun2ms(fn {key, name, job} when key > 3 -> key end)
# [{{:"$1", :"$2", :"$3"}, [{:>, :"$1", 3}], [[:"$1", :"$2", :"$3"]]}]

# vamos pegar esse resultado e modificar para se usado no select/2
[{{Person, :"$1", :"$2", :"$3"}, [{:>, :"$1", 3}], [[:"$$"]]}]

# Inicialização de dados e migração
# A cada evolução de software, virá a hora quando você precisará atualizar o software
# e migrar os dados armazenados em seu banco de dados.

# Por exemplo, talvez precisaremos adicionar uma coluna em nossa tabela na v2 da nossa aplicação.
# se quisermos adicionar uma coluna :age nós não podemos criar a tabela Person uma vez que ela já foi criada,
# e esta preenchida, mas podemos transformá-la.

# Para isso precisamos saber quando transformar, o qual podemos fazer quando estamos criando a tabela.
# Para fazer isto, podemos usar a função :mnesia.table_info/2 para buscar a estrutura atual da tabela
# e a função :mnesia.transform_table/3 para transformá-la na nova estrutura.

table_info(Tab :: table(), Item :: term()) -> Info :: term()

transform_table(Tab :: table(), Fun, NewA :: [Attr]) -> t_result(ok)

# vamos fazer a seguinte implementação
# criar a tabela com os atributos da v2: [:id, :name, :job, :age]
# tratar o resultado da criação
# caso {:atomic, :ok} inicializa a tabela criando índices em :job e :age
# caso {:aborted, {:already_exists, Person}} verificar quais os atributos estão na tabela atual e agir em conformidade
#   se for a lista v1 ([:id, :name, :job]), transforme a tabela dando uma idade de 00 anos para todos
#     e adiciona um novo índice em :age.
#   se for a lista v2, não faça nada, tudo bem.
#   se for algo diferente, descarta.

# Se estivermos executando alguma ação nas tabelas existentes logo após iniciar o Mnesia com :mnesia.start/0,
# essas tabelas podem não ser inicializadas e acessíveis. Nesse caso, devemos usar a função :mnesia.wait_for_tables/2.
# Ela suspenderá o processo atual até que as tabelas sejam inicializadas ou até que o tempo limite seja atingido.
wait_for_tables(Tabs :: [Tab :: table()], TMO :: timeout()) -> result() | {timeout, [table()]}

# A função :mnesia.transform_table/3 recebe como atributos o nome da tabela, a função que transforma o registro
# do formato antigo para o novo, e a lista de novos atributos.

iex(hr@dev.com)> case :mnesia.create_table(Person, [attributes: [:id, :name, :job, :age]]) do
       {:atomic, :ok} ->
         :mnesia.add_table_index(Person, :job)
         :mnesia.add_table_index(Person, :age)

       {:aborted, {:already_exists, Person}} ->
         case :mnesia.table_info(Person, :attributes) do
           [:id, :name, :job] ->
             :mnesia.wait_for_tables([Person], 5000)
             :mnesia.transform_table(
               Person,
               fn ({Person, id, name, job}) ->
                 {Person, id, name, job, 21}
               end,
               [:id, :name, :job, :age]
             )
           :mnesia.add_table_index(Person, :age)

           [:id, :name, :job, :age] ->
             :ok

           other ->
             {:error, other}
    end
end

iex(hr@dev.com)> :mnesia.table_info(Person, :attributes)
# [:id, :name, :job, :age]

iex(hr@dev.com)> :mnesia.transaction(
  fn ->
    :mnesia.write({Person, 1, "Nome 1", "home maker", 25})
  end
)
# {:atomic, :ok}

iex(hr@dev.com)> :mnesia.transaction(
  fn ->
    :mnesia.read({Person, 5})
  end
)
# {:atomic, [{Person, 1, "Nome 1", "home maker", 25}]}

iex(hr@dev.com)> :mnesia.transaction(
  fn ->
    :mnesia.select(Person, [{{Person, :"$1", :"$2", :"$3", :"$4"}, [{:>=, :"$1", 1}], [:"$$"]}])
  end
)
# {:atomic, [[1, "Nome 1", "home maker", 25]]}
