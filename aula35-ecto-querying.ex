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
iex> query = from(Movie)
#Ecto.Query<from m0 in Company.Movie>
