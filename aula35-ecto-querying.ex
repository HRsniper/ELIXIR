# Buscando Registros com Ecto.Repo
# Um “repositório” no Ecto é mapeado para um armazenamento de dados, como nosso banco de dados Postgres.
# Toda a comunicação com o banco de dados será feita usando este repositório.
# Podemos realizar consultas diretamente em nosso modulo Company.Repo com a ajuda de algumas funções Callbacks.

iex> alias Company.{Movie, Character, Repo, Actor}
# Buscando Registros por ID
# get(queryable, id, opts)
  # Busca uma única estrutura do armazenamento de dados onde a chave primária corresponde ao ID fornecido.

iex> Repo.get(Movie, 1)
# iex> Repo.get(Movie, 1, prefix: "public")
# SELECT m0."id", m0."title", m0."tagline" FROM "movies" AS m0 WHERE (m0."id" = $1) [1]
# %Company.Movie{
#   __meta__: #Ecto.Schema.Metadata<:loaded, "movies">,
#   actors: #Ecto.Association.NotLoaded<association :actors is not loaded>,
#   characters: #Ecto.Association.NotLoaded<association :characters is not loaded>,
#   distributor: #Ecto.Association.NotLoaded<association :distributor is not loaded>,
#   id: 1,
#   tagline: "Something about video games",
#   title: "Ready Player One"
# }
# o primeiro argumento que fornecemos a Repo.get/3 foi nosso módulo Movie.
# Movie é “queryable” pois o módulo usa Ecto.Schema e define um schema para sua estrutura de dados.
# Isso dá a Movie acesso ao protocolo Ecto.Queryable. Esse protocolo converte uma estrutura de dados
# em um Ecto.Query. Ecto queries são usadas para recuperar dados de um repositório.

# Buscando Registros por Atributo
# get_by(queryable, clauses, opts)
  # Busca um único resultado da consulta.

iex> Repo.get_by(Movie, title: "Ready Player One")
# SELECT m0."id", m0."title", m0."tagline" FROM "movies" AS m0 WHERE (m0."title" = $1) ["Ready Player One"]
# %Company.Movie{
#   __meta__: #Ecto.Schema.Metadata<:loaded, "movies">,
#   actors: #Ecto.Association.NotLoaded<association :actors is not loaded>,
#   characters: #Ecto.Association.NotLoaded<association :characters is not loaded>,
#   distributor: #Ecto.Association.NotLoaded<association :distributor is not loaded>,
#   id: 1,
#   tagline: "Something about video games",
#   title: "Ready Player One"
# }

# resto das callbacks: https://hexdocs.pm/ecto/3.5.8/Ecto.Repo.html#summary

# Escrevendo Consultar com Ecto.Query
# O módulo Ecto.Query nos fornece a DSL de consulta,
# que podemos usar para recuperar e manipular dados de um repositório

iex> import Ecto.Query
# Ecto.Query

# Criando Consultas baseadas em palavras-chave com Ecto.Query.from/2
# from (expr, kw \\ [])
# Cria uma consulta. Pode ser uma consulta de palavra-chave ou uma expressão de consulta.

iex> query = from(Movie)
#Ecto.Query<from m0 in Company.Movie>

# all(queryable, opts)
  # Busca todas as entradas do armazenamento de dados que correspondem à consulta fornecida.

iex> Repo.all(query)
# SELECT m0."id", m0."title", m0."tagline" FROM "movies" AS m0 []
# [
#   %Company.Movie{
#     __meta__: #Ecto.Schema.Metadata<:loaded, "movies">,
#     actors: #Ecto.Association.NotLoaded<association :actors is not loaded>,
#     characters: #Ecto.Association.NotLoaded<association :characters is not loaded>,
#     distributor: #Ecto.Association.NotLoaded<association :distributor is not loaded>,
#     id: 1,
#     tagline: "Something about video games",
#     title: "Ready Player One"
#   }
# ]

# Consultas bindingless com from
# O exemplo acima não tem a parte mais divertida das declarações (statements) SQL.
# Nós frequentemente queremos não apenas buscar campos específicos ou filtrar registros por alguma condição.
# Vamos carregar title e tagline de todos os filmes que tenham o título "Ready Player One":
iex> query = from(Movie, where: [title: "Ready Player One"], select: [:title, :tagline])
#Ecto.Query<from m0 in Company.Movie, where: m0.title == "Ready Player One", select: [:title, :tagline]>

iex> Repo.all(query)
# SELECT m0."title", m0."tagline" FROM "movies" AS m0 WHERE (m0."title" = 'Ready Player One') []
# [
#   %Company.Movie{
#     __meta__: #Ecto.Schema.Metadata<:loaded, "movies">,
#     actors: #Ecto.Association.NotLoaded<association :actors is not loaded>,
#     characters: #Ecto.Association.NotLoaded<association :characters is not loaded>,
#     distributor: #Ecto.Association.NotLoaded<association :distributor is not loaded>,
#     id: nil,
#     tagline: "Something about video games",
#     title: "Ready Player One"
#   }
# ]

# A estrutura (struct) retornada tem somente os campos tagline e title,
# esse é o resultado da parte do nosso select:.
# Consultas como esta são chamadas bindingless, porque elas são simples o suficiente para não requerer bindings.

# Bindings em consultas
# Até agora, nós usamos um módulo para implementar o protocolo Ecto.Queryable (ex: Movie)
# como o primeiro argumento da `from`. No entanto, nós podemos usar também a expressão in

iex> query = from(m in Movie)
#Ecto.Query<from m0 in Friends.Movie>
# nós chamamos m de binding (atribuição).
# Bindings são extremamente úteis, porque eles permitem que nós referenciemos módulos em
# outras partes de uma consulta (query).

# Vamos selecionar os títulos de todos os filmes que tenham o id menor que 2
iex> query = from(m in Movie, where: m.id < 2, select: m.title)
#Ecto.Query<from m0 in Friends.Movie, where: m0.id < 2, select: m0.title>

iex> Repo.all(query)
# SELECT m0."title" FROM "movies" AS m0 WHERE (m0."id" < 2) []
# ["Ready Player One"]

# Um ponto muito importante aqui é como a saída de uma consulta é alterada.
# Usando uma expressão com uma atribuição na parte do select:
# isso nos permite especificar exatamente a forma como os campos selecionados serão retornados.
# Nós podemos solicitar o retorno como uma tupla.
iex> query = from(m in Movie, where: m.id < 2, select: {m.title})
#Ecto.Query<from m0 in Company.Movie, where: m0.id < 2, select: {m0.title}>
iex> Repo.all(query)
# SELECT m0."title" FROM "movies" AS m0 WHERE (m0."id" < 2) []
# [{"Ready Player One"}]

# É sempre uma boa ideia começar com uma consulta simples sem atribuição (bindingless)
# e introduzir a atribuição sempre que você precisar referenciar sua estrutura de dados.

# Consultas baseadas em macros
# até agora nós usamos as palavras-chave select: e where: dentro da macro `from` para construir uma consulta (query),
# essas são chamadas de consultas baseadas em palavras-chave.

# mas há outra forma de compor consultas, se baseia em macros.
# Ecto fornece macros para cada palavra-chave, como select/3 or where/3.

# select (query, binding \\ [], expr)
  # Uma expressão de consulta selecionada. Seleciona quais campos serão selecionados no esquema e
  # quaisquer transformações que devem ser executadas nos campos. Qualquer expressão aceita em uma
  # consulta pode ser um campo de seleção.
  # Select também permite que cada expressão seja agrupada em listas, tuplas ou mapas.
  # Um esquema completo também pode ser selecionado.

# where(query, binding \\ [], expr)
  # AND e query expressão de consulta.
  # onde as expressões são usadas para filtrar o conjunto de resultados.
  # Se houver mais de um where expression, eles serão combinados com um operador and.
  # onde também aceita uma lista de palavras-chave em que o campo fornecido como chave será comparado
  #  com o valor fornecido. Os campos sempre se referirão à fonte fornecida `from`.

# Cada macro aceita um valor queryable (buscável), uma lista explícita de bindings
# e a mesma expressão que você forneceu para sua consulta de palavras-chave análoga;

iex> query = select(Movie, [m], m.title)
#Ecto.Query<from m0 in Friends.Movie, select: m0.title>
iex> Repo.all(query)
# SELECT m0."title" FROM "movies" AS m0 []
# ["Ready Player One"]

# com macros pode-se trabalhar com pipes.
iex> Movie |> where([m], m.id < 2) |> select([m], {m.title}) |> Repo.all
# SELECT m0."title" FROM "movies" AS m0 WHERE (m0."id" < 2) []
# [{"Ready Player One"}]

# se quiser continuar escrevendo depois da quebra de linha, use o caracter \.
iex> Movie \
...>  |> where([m], m.id < 2) \
...>  |> select([m], {m.title}) \
...>  |> Repo.all
# SELECT m0."title" FROM "movies" AS m0 WHERE (m0."id" < 2) []
# [{"Ready Player One"}]

# Usando where com Valores Interpolados
