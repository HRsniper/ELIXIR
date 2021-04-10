# Tipos de Associações
# Existem três tipos de associações que podem ser definidas entre nossos esquemas.
  # Belongs To/Has Many
  # Belong To/Has One
  # many to many(Muitos para muitos)

# Belongs To/Has Many
# Vamos adicionar novas entidades ao modelo de domínio da nossa aplicação Company
# para que seja possível categorizar nossos os filmes favoritos dos funcionários.
# Vamos iniciar com dois esquemas: Movie e Character. Vamos implementar uma relação “has many/belongs to”
# entre os dois: Um filme tem vários (has many) personagens e um personagem pertence a (belongs to) um filme.

# Vamos gerar uma migração para Movie:
$ mix ecto.gen.migration create_movies

# Migration Has Many
# em priv\repo\migrations\***_create_movies.exs
def change do
  create table(:movies) do
    add :title, :string
    add :tagline, :string
  end
end

# O Schema Has Many
# Nós vamos adicionar um esquema que especifica a relação “has many” entre um filme e os seus personagens.
# em lib\company\favorite_movie.ex
defmodule Company.FavoriteMovie do
  use Ecto.Schema

  schema "favorite_movies" do
    field :title, :string
    field :tagline, :string
    has_many :movie_characters, Company.MovieCharacter
  end
end

# has_many(name, queryable, opts \\ [])
  # Indica uma associação um para muitos com outro esquema.

# A macro has_many/3 não adiciona dados ao banco de dados por si só.
# O que ela faz é utilizar uma chave estrangeira no esquema associado (movie_characters)
# para tornar as associações de personagens de um filme disponíveis.
# Isso é o que nos permite realizar chamadas como favorite_movies.movie_characters.

# Um personagem pertence(belongs to) a um filme, então vamos definir uma migração
# que especifique o relacionamento.
$ mix ecto.gen.migration create_characters

# Migration Belongs
# em priv/migrations/***_create_characters.exs
def change do
  create table(:movie_characters) do
    add :name, :string
    add :movie_id, references(:favorite_movies)
  end
end

# references(table, opts \\ [])
  # Define uma chave estrangeira.

# O Schema Belongs To
# Nosso esquema precisa definir a relação belongs to entre um personagem e seu filme.
# lib/friends/character.ex
defmodule Friends.MovieCharacter do
  use Ecto.Schema

  schema "movie_characters" do
    field :name, :string
    belongs_to :favorite_movies, Company.FavoriteMovie
  end
end

# belongs_to(name, queryable, opts \\ [])
  # Indica uma associação um para um ou muitos para um com outro esquema.

# Ela utiliza a chave estrangeira para tornar o filme associado a um personagem disponível
# quando executamos a consulta sobre os personagens. Isso nos permite chamar movie_characters.favorite_movies.

# Agora vamos para executar as migrações:
$ mix ecto.migrate
# hh:mm:ss.ms [info]  == Running 20210410175047 Company.Repo.Migrations.CreateMovies.change/0 forward
# hh:mm:ss.ms [info]  create table favorite_movies
# hh:mm:ss.ms [info]  == Migrated 20210410175047 in 0.6s
# hh:mm:ss.ms [info]  == Running 20210410180425 Friends.Repo.Migrations.CreateCharacters.change/0 forward
# hh:mm:ss.ms [info]  create table movie_characters
# hh:mm:ss.ms [info]  == Migrated 20210410180425 in 0.1s

# Belong To/Has One
# Digamos que um filme tenha um distribuidor. Por exemplo, o Disney é o distribuidor de Vingadores.
# Vamos definir a migração e o esquema Distributor com o relacionamento “belongs to”.
$ mix ecto.gen.migration create_distributors

# Nós devemos adicionar uma chave estrangeira de movie_id à migração da tabela distributors
# que acabamos de gerar, bem como um índice único (unique) para garantir que um filme tenha
# apenas um distribuidor.

# em priv/repo/migrations/*_create_distributors.exs
def change do
  create table(:distributors) do
    add :name, :string
    add :movie_id, references(:favorite_movies)
  end

  create unique_index(:distributors, [:movie_id])
end

# unique_index(table, columns, opts \\ [])
  # Atalho para criar um índice único.

# E o esquema Distributor deve usar a macro belongs_to/3 para nos permitir chamar distributor.favorite_movies
# e procurar o filme associado a um distribuidor usando esta chave estrangeira.
# lib/company/distributor.ex
defmodule Company.Distributor do
  use Ecto.Schema

  schema "distributors" do
    field(:name, :string)
    belongs_to(:favorite_movies, Company.FavoriteMovie)
  end
end

# Em seguida, adicionaremos o relacionamento “has one” ao esquema FavoriteMovie.
schema "movies" do
  ...
  has_one :distributor, Company.Distributor
end

# has_one(name, queryable, opts \\ [])
  # Indica uma associação um a um com outro esquema.

# A macro has_one/3 funciona como a macro has_many/3. Ela usa a chave estrangeira do esquema para procurar
# e expor o distribuidor do filme. Isso nos permitirá chamar favorite_movie.distributor.

# Agora vamos para executar as migrações:
$ mix ecto.migrate
# hh:mm:ss.ms [info]  == Running 20210410182400 Friends.Repo.Migrations.CreateDistributors.change/0 forward
# hh:mm:ss.ms [info]  create table distributors
# hh:mm:ss.ms [info]  create index distributors_movie_id_index
# hh:mm:ss.ms [info]  == Migrated 20210410182400 in 0.1s

# Muitos para muitos(many to many)
# Digamos que um filme tenha muitos atores e que um ator possa pertencer a mais de um filme.
# Vamos construir uma tabela de relação que faça referência a ambos filmes(movies) e atores(actors)
# para implementar esse relacionamento.
$ mix ecto.gen.migration create_actors

# em priv/repo/migrations/***_create_actors.exs
def change do
  create table(:actors) do
    add :name, :string
  end
end

# Vamos gerar nossa migração da tabela de relacionamento
$ mix ecto.gen.migration create_movies_actors

# em priv/repo/migrations/***_create_movies_actors.exs
def change do
  create table(:movies_actors) do
    add :movie_id, references(:movies)
    add :actor_id, references(:actors)
  end

  create unique_index(:movies_actors, [:movie_id, :actor_id])
end

# Em seguida, vamos adicionar a macro many_to_many ao nosso esquema Favorite_Movie:
# lib/company/favorite_movie.ex
  schema "favorite_movies" do
    ...
    many_to_many :actors, Company.Actor, join_through: "movies_actors"
  end

# many_to_many(name, queryable, opts \\ [])
  # Indica uma associação muitos para muitos com outro esquema.
  # :join_through - especifica a fonte dos dados associados.

# Finalmente, definiremos nosso esquema Actor com a mesma macro many_to_many.
# lib/company/actor.ex
defmodule Company.Actor do
  use Ecto.Schema

  schema "actors" do
    field :name, :string
    many_to_many :favorite_movies, Company.FavoriteMovie, join_through: "movies_actors"
  end
end

# Agora vamos para executar as migrações:
$ mix ecto.migrate
# hh:mm:ss.ms [info]  == Running 20210410184225 Company.Repo.Migrations.CreateActors.change/0 forward
# hh:mm:ss.ms [info]  create table actors
# hh:mm:ss.ms [info]  == Migrated 20210410184225 in 0.0s
# hh:mm:ss.ms [info]  == Running 20210410184349 Company.Repo.Migrations.CreateMoviesActors.change/0 forward
# hh:mm:ss.ms [info]  create table movies_actors
# hh:mm:ss.ms [info]  create index movies_actors_movie_id_actor_id_index
# hh:mm:ss.ms [info]  == Migrated 20210410184349 in 0.0s

# Salvando Dados Associados
# A maneira como salvamos registros junto dos dados associados depende da natureza do relacionamento
# entre os registros. Vamos começar com o relacionamento “Belongs to/has many”.

# build_assoc(struct, assoc, attributes \\ %{})
  # Constrói uma estrutura a partir da estrutura associada fornecida.

# Com um relacionamento “belongs to”, podemos alavancar a função build_assoc/3 do Ecto
  # build_assoc/3 aceita três argumentos:
  # A estrutura do registro que queremos salvar.
  # O nome da associação.
  # Quaisquer atributos que queremos atribuir ao registro associado que estamos salvando.

# vamos criar um registro de filme
iex> movie_struct = %Company.Movie{title: "filme", tagline: "tag do filme"}
# %Company.Movie{
#   __meta__: #Ecto.Schema.Metadata<:built, "movies">,
#   actors: #Ecto.Association.NotLoaded<association :actors is not loaded>,
#   distributor: #Ecto.Association.NotLoaded<association :distributor is not loaded>,
#   id: nil,
#   movie_characters: #Ecto.Association.NotLoaded<association :movie_characters is not loaded>,
#   tagline: "tag do filme",
#   title: "filme"
# }
iex> movie = Company.Repo.insert!(movie_struct)
# INSERT INTO "movies" ("tagline","title") VALUES ($1,$2) RETURNING "id" ["tag do filme", "filme"]
# %Company.Movie{
#   __meta__: #Ecto.Schema.Metadata<:loaded, "movies">,
#   actors: #Ecto.Association.NotLoaded<association :actors is not loaded>,
#   characters: #Ecto.Association.NotLoaded<association :characters is not loaded>,
#   distributor: #Ecto.Association.NotLoaded<association :distributor is not loaded>,
#   id: 1,
#   tagline: "tag do filme",
#   title: "filme"
# }
iex> character = Ecto.build_assoc(movie, :characters, %{name: "Ator do filme"})
iex> Company.Repo.insert!(character)
iex> distributor = Ecto.build_assoc(movie, :distributor, %{name: "Netflix"})
iex> Repo.insert!(distributor)

# Many to Many
# Salvando com Ecto.Changeset.put_assoc/4

# put_assoc(changeset, name, value, opts \\ [])
  # Coloca o dado entrada associação ou entradas como uma mudança no conjunto de alterações.

iex> actor_struct = %Company.Actor{name: "Tyler Sheridan"}
# %Company.Actor{
#   __meta__: #Ecto.Schema.Metadata<:built, "actors">,
#   id: nil,
#   movies: #Ecto.Association.NotLoaded<association :movies is not loaded>,
#   name: "Tyler Sheridan"
# }
iex> actor = Company.Repo.insert!(actor_struct)
# INSERT INTO "actors" ("name") VALUES ($1) RETURNING "id" ["Tyler Sheridan"]
# %Company.Actor{
#   __meta__: #Ecto.Schema.Metadata<:loaded, "actors">,
#   id: 1,
#   movies: #Ecto.Association.NotLoaded<association :movies is not loaded>,
#   name: "Tyler Sheridan"
# }

# trabalhar com Changesets, precisamos ter certeza de que nossa estrutura movie pré-carregou
# seus esquemas associados.

iex> movie = Company.Repo.preload(movie, [:distributor, :characters, :actors])
# Em seguida, criaremos um conjunto de alterações para nosso registro de filme:
iex> movie_changeset = Ecto.Changeset.change(movie)

iex> movie_actors_changeset = movie_changeset |> Ecto.Changeset.put_assoc(:actors, [actor])
# Isso nos dá um novo changeset, representando a seguinte mudança: adicione os atores nesta lista de atores ao registro de filme dado.

iex> Company.Repo.update!(movie_actors_changeset)
# atualizaremos os registros de filme e ator fornecidos usando nosso changeset mais recente
# isso nos dá um registro de filme com o novo ator apropriadamente associado e já pré-carregado para nós em movie.actors.

# Podemos usar essa mesma abordagem para criar um novo ator associado ao filme em questão.
iex> changeset = movie_changeset |> Ecto.Changeset.put_assoc(:actors, [%{name: "Gary"}])
# um novo ator vai criado com um ID “2” e os atributos que atribuímos a ele.
