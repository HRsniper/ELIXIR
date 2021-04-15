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
  # com o valor fornecido. Os campos sempre se referirão à fonte fornecida `from`.

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
# Para usar valores interpolados ou expressões Elixir em nossas cláusulas where,
# precisamos usar o operador pin ^ .Isso nos permite fixar um valor para uma variável
# e se referir ao valor fixado, em vez de vincular essa variável.

iex> title = "Ready Player One"
# "Ready Player One"
iex> query = from(m in Movie, where: m.title == ^title, select: m.tagline)
#Ecto.Query<from m0 in Company.Movie, where: m0.title == ^"Ready Player One", select: m0.tagline>
iex> Repo.all(query)
# SELECT m0."tagline" FROM "movies" AS m0 WHERE (m0."title" = $1) ["Ready Player One"]
# ["Something about video games"]

# Obtendo o Primeiro e o Último Registro
# Podemos buscar o primeiro ou último registro de um repositório usando as
# funções Ecto.Query.first/2 e Ecto.Query.last/2.

# first(queryable, order_by \\ nil)
  # Restringe a consulta para retornar o primeiro resultado ordenado por chave primária.

# last(queryable, order_by \\ nil)
  # Restringe a consulta para retornar o último resultado ordenado por chave primária.

iex> first(Movie)
#Ecto.Query<from m0 in Company.Movie, order_by: [asc: m0.id], limit: 1>
iex> last(Movie)
#Ecto.Query<from m0 in Company.Movie, order_by: [desc: m0.id], limit: 1>

# Então passamos nossa consulta para a função Repo.one/2 para obter nosso resultado
# one(queryable, opts)
  # Busca um único resultado da consulta.
  # Retorna nil se nenhum resultado foi encontrado. Gera um erro se houver mais de uma entrada.

iex> Movie |> first() |> Repo.one()
# SELECT m0."id", m0."title", m0."tagline" FROM "movies" AS m0 ORDER BY m0."id" LIMIT 1 []
# %Company.Movie{
#   __meta__: #Ecto.Schema.Metadata<:loaded, "movies">,
#   actors: #Ecto.Association.NotLoaded<association :actors is not loaded>,
#   characters: #Ecto.Association.NotLoaded<association :characters is not loaded>,
#   distributor: #Ecto.Association.NotLoaded<association :distributor is not loaded>,
#   id: 1,
#   tagline: "Something about video games",
#   title: "Ready Player One"
# }
iex> Movie |> last() |> Repo.one()
# SELECT m0."id", m0."title", m0."tagline" FROM "movies" AS m0 ORDER BY m0."id" DESC LIMIT 1 []
# %Company.Movie{
#   __meta__: #Ecto.Schema.Metadata<:loaded, "movies">,
#   actors: #Ecto.Association.NotLoaded<association :actors is not loaded>,
#   characters: #Ecto.Association.NotLoaded<association :characters is not loaded>,
#   distributor: #Ecto.Association.NotLoaded<association :distributor is not loaded>,
#   id: 1,
#   tagline: "Something about video games",
#   title: "Ready Player One"
# }

# Consulta Para Dados Associados
  # Pré-carregamento
# Para poder acessar os registros associados que os macros belongs_to, has_many e has_one nos expõem,
# precisamos pré-carregar os esquemas associados.

iex> movie = Repo.get(Movie, 1)
iex> movie.title
# "Ready Player One"
iex> movie.actors
# %Ecto.Association.NotLoaded<association :actors is not loaded>

# Não podemos acessar esses atores associados, a menos que os pré-carreguemos.
# Existem algumas maneiras diferentes de pré-carregar registros com o Ecto.

# Pré-carregamento Com Duas Consultas
# Essa consulta pré-carregará os registros associados em uma consultas separadas.
iex> Repo.all(from m in Movie, preload: [:actors])
# SELECT m0."id", m0."title", m0."tagline" FROM "movies" AS m0 []
# SELECT a0."id", a0."name", m1."movie_id"::bigint FROM "actors" AS a0 INNER JOIN "movies_actors" AS m1 ON a0."id" = m1."actor_id" WHERE (m1."movie_id" = ANY($1)) ORDER BY m1."movie_id"::bigint [[1]]
# [
#   %Company.Movie{
#     __meta__: #Ecto.Schema.Metadata<:loaded, "movies">,
#     actors: [
#       %Company.Actor{
#         __meta__: #Ecto.Schema.Metadata<:loaded, "actors">,
#         id: 1,
#         movies: #Ecto.Association.NotLoaded<association :movies is not loaded>,
#         name: "Tyler Sheridan"
#       },
#       %Company.Actor{
#         __meta__: #Ecto.Schema.Metadata<:loaded, "actors">,
#         id: 2,
#         movies: #Ecto.Association.NotLoaded<association :movies is not loaded>,
#         name: "Gary"
#       }
#     ],
#     characters: #Ecto.Association.NotLoaded<association :characters is not loaded>,
#     distributor: #Ecto.Association.NotLoaded<association :distributor is not loaded>,
#     id: 1,
#     tagline: "Something about video games",
#     title: "Ready Player One"
#   }
# ]

# Pré-carregamento Com Uma Consulta
# assoc (struct_or_structs, associates)
  # Constrói uma consulta para a associação em uma determinada estrutura de structs.

iex> query = from(m in Movie, join: a in assoc(m, :actors), preload: [actors: a])
#Ecto.Query<from m0 in Company.Movie, join: a1 in assoc(m0, :actors), preload: [actors: a1]>
iex> Repo.all(query)
# SELECT m0."id", m0."title", m0."tagline", a1."id", a1."name" FROM "movies" AS m0 INNER JOIN "movies_actors" AS m2 ON m2."movie_id" = m0."id" INNER JOIN "actors" AS a1 ON m2."actor_id" = a1."id" []
# [
#   %Company.Movie{
#     __meta__: #Ecto.Schema.Metadata<:loaded, "movies">,
#     actors: [
#       %Company.Actor{
#         __meta__: #Ecto.Schema.Metadata<:loaded, "actors">,
#         id: 1,
#         movies: #Ecto.Association.NotLoaded<association :movies is not loaded>,
#         name: "Tyler Sheridan"
#       },
#       %Company.Actor{
#         __meta__: #Ecto.Schema.Metadata<:loaded, "actors">,
#         id: 2,
#         movies: #Ecto.Association.NotLoaded<association :movies is not loaded>,
#         name: "Gary"
#       }
#     ],
#     characters: #Ecto.Association.NotLoaded<association :characters is not loaded>,
#     distributor: #Ecto.Association.NotLoaded<association :distributor is not loaded>,
#     id: 1,
#     tagline: "Something about video games",
#     title: "Ready Player One"
#   }
# ]

# com assoc/2 junto com a instrução join, nos permitir selecionar e filtrar filmes e atores
# associados que atendem a determinadas condições na mesma consulta.
iex> Repo.all from m in Movie,
       join: a in assoc(m, :actors),
       where: a.name == "John Wayne",
       preload: [actors: a]
# SELECT m0."id", m0."title", m0."tagline", a1."id", a1."name" FROM "movies" AS m0 INNER JOIN "movies_actors" AS m2 ON m2."movie_id" = m0."id" INNER JOIN "actors" AS a1 ON m2."actor_id" = a1."id" WHERE (a1."name" = 'John Wayne') []
# []

iex> Repo.all from m in Movie,
       join: a in assoc(m, :actors),
       where: a.name == "Gary",
       preload: [actors: a]
# SELECT m0."id", m0."title", m0."tagline", a1."id", a1."name" FROM "movies" AS m0 INNER JOIN "movies_actors" AS m2 ON m2."movie_id" = m0."id" INNER JOIN "actors" AS a1 ON m2."actor_id" = a1."id" WHERE (a1."name" = 'Gary') []
# [
#   %Company.Movie{
#     __meta__: #Ecto.Schema.Metadata<:loaded, "movies">,
#     actors: [
#       %Company.Actor{
#         __meta__: #Ecto.Schema.Metadata<:loaded, "actors">,
#         id: 2,
#         movies: #Ecto.Association.NotLoaded<association :movies is not loaded>,
#         name: "Gary"
#       }
#     ],
#     characters: #Ecto.Association.NotLoaded<association :characters is not loaded>,
#     distributor: #Ecto.Association.NotLoaded<association :distributor is not loaded>,
#     id: 1,
#     tagline: "Something about video games",
#     title: "Ready Player One"
#   }
# ]

# Pré-carregamento de Registros já Buscados
# Também podemos pré-carregar os esquemas associados de registros que já foram consultados no banco de dados.
iex> movie = Repo.get(Movie, 1)
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
iex> movie = Repo.preload(movie, :actors)
# SELECT a0."id", a0."name", m1."movie_id"::bigint FROM "actors" AS a0 INNER JOIN "movies_actors" AS m1 ON a0."id" = m1."actor_id" WHERE (m1."movie_id" = ANY($1)) ORDER BY m1."movie_id"::bigint [[1]]
# %Company.Movie{
#   __meta__: #Ecto.Schema.Metadata<:loaded, "movies">,
#   actors: [
#     %Company.Actor{
#       __meta__: #Ecto.Schema.Metadata<:loaded, "actors">,
#       id: 1,
#       movies: #Ecto.Association.NotLoaded<association :movies is not loaded>,
#       name: "Tyler Sheridan"
#     },
#     %Company.Actor{
#       __meta__: #Ecto.Schema.Metadata<:loaded, "actors">,
#       id: 2,
#       movies: #Ecto.Association.NotLoaded<association :movies is not loaded>,
#       name: "Gary"
#     }
#   ],
#   characters: #Ecto.Association.NotLoaded<association :characters is not loaded>,
#   distributor: #Ecto.Association.NotLoaded<association :distributor is not loaded>,
#   id: 1,
#   tagline: "Something about video games",
#   title: "Ready Player One"
# }

iex> movie.actors
# [
#   %Company.Actor{
#     __meta__: #Ecto.Schema.Metadata<:loaded, "actors">,
#     id: 1,
#     movies: #Ecto.Association.NotLoaded<association :movies is not loaded>,
#     name: "Tyler Sheridan"
#   },
#   %Company.Actor{
#     __meta__: #Ecto.Schema.Metadata<:loaded, "actors">,
#     id: 2,
#     movies: #Ecto.Association.NotLoaded<association :movies is not loaded>,
#     name: "Gary"
#   }
# ]


# Usando a Instrução Join
# Podemos executar consultas que incluem instruções de junção com a ajuda da função Ecto.Query.join/5.

# join(query, qual, binding \\ [], expr, opts \\ [])
#   Uma expressão de consulta de junção.
#   Recebe uma fonte que deve ser unida à consulta e uma condição para a junção.
#   A condição de junção pode ser qualquer expressão avaliada como um valor booleano.
#   O qualificador deve ser um dos :inner, :left, :right, :cross, :full, :inner_lateral ou :left_lateral.
#     Para uma consulta de palavra-chave, a palavra-chave :join pode ser alterada
#     para :inner_join, :left_join, :right_join, :cross_join, :full_join, :inner_lateral_join ou :left_lateral_join.
#     :join é equivalente a :inner_join.
# opts => :on - uma expressão de consulta ou lista de palavras-chave para filtrar a junção

iex> query = from m in Movie,
             join: c in Character,
             on: m.id == c.movie_id,
            # on: [id: c.movie_id], # lista de palavras-chave
             where: c.name == "Wade Watts",
             select: {m.title, c.name}
#Ecto.Query<from m0 in Company.Movie, join: c1 in Company.Character,
# on: m0.id == c1.movie_id, where: c1.name == "Wade Watts",
# select: {m0.title, c1.name}>
iex> Repo.all(query)
# SELECT m0."title", c1."name" FROM "movies" AS m0 INNER JOIN "characters" AS c1 ON m0."id" = c1."movie_id" WHERE (c1."name" = 'Wade Watts') []
# [{"Ready Player One", "Wade Watts"}]

iex> movie = from m in Movie, where: [id: 1]
#Ecto.Query<from m0 in Company.Movie, where: m0.id == 1>
iex> movies = from m in Movie, where: m.id < 2
#Ecto.Query<from m0 in Company.Movie, where: m0.id < 2>
iex> from c in Character,
       join: m in ^movies,
       on: [id: c.movie_id],
       where: c.name == "Wade Watts",
       select: {m.title, c.name}
#Ecto.Query<from c0 in Company.Character,
# join: m1 in ^#Ecto.Query<from m0 in Company.Movie, where: m0.id < 2>,
# on: m1.id == c0.movie_id, where: c0.name == "Wade Watts",
# select: {m1.title, c0.name}>
iex> Repo.all(query)
# SELECT m1."title", c0."name" FROM "characters" AS c0 INNER JOIN "movies" AS m1 ON (m1."id" < 2) AND (m1."id" = c0."movie_id") WHERE (c0."name" = 'Wade Watts') []
# [{"Ready Player One", "Wade Watts"}]

# A DSL Ecto Query é uma ferramenta poderosa que nos fornece tudo o que precisamos para fazer consultas complexas em bancos de dados.
