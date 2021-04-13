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
defmodule Company.Movie do
  use Ecto.Schema

  schema "movies" do
    field :title, :string
    field :tagline, :string
    has_many :characters, Company.Character
    # has_many :characters, Company.Character, references: :id
  end
end

# has_many(name, queryable, opts \\ [])
  # Indica uma associação um para muitos com outro esquema.

# A macro has_many/3 não adiciona dados ao banco de dados por si só.
# O que ela faz é utilizar uma chave estrangeira no esquema associado (characters)
# para tornar as associações de personagens de um filme disponíveis.
# Isso é o que nos permite realizar chamadas como movies.characters.

# Um personagem pertence(belongs to) a um filme, então vamos definir uma migração
# que especifique o relacionamento.
$ mix ecto.gen.migration create_characters

# Migration Belongs
# em priv/migrations/***_create_characters.exs
def change do
  create table(:characters) do
    add :name, :string
    add :movie_id, references(:movies)
  end
end

# references(table, opts \\ [])
  # Define uma chave estrangeira.

# O Schema Belongs To
# Nosso esquema precisa definir a relação belongs to entre um personagem e seu filme.
# lib/friends/character.ex
defmodule Company.Character do
  use Ecto.Schema

  schema "characters" do
    field :name, :string
    belongs_to :movie, Company.Movie
    # belongs_to :movie, Company.Movie, references: :id
  end
end

# belongs_to(name, queryable, opts \\ [])
  # name = nome do modulo => :movie = Movie
  # Indica uma associação um para um ou muitos para um com outro esquema.

# Ela utiliza a chave estrangeira para tornar o filme associado a um personagem disponível
# quando executamos a consulta sobre os personagens. Isso nos permite chamar movie.characters.movies.

# Agora vamos para executar as migrações:
$ mix ecto.migrate
# hh:mm:ss.ms [info]  == Running 20210410175047 Company.Repo.Migrations.CreateMovies.change/0 forward
# hh:mm:ss.ms [info]  create table movies
# hh:mm:ss.ms [info]  == Migrated 20210410175047 in 0.6s
# hh:mm:ss.ms [info]  == Running 20210410180425 Friends.Repo.Migrations.CreateCharacters.change/0 forward
# hh:mm:ss.ms [info]  create table characters
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
    add :movie_id, references(:movies)
  end

  create unique_index(:distributors, [:movie_id])
end

# unique_index(table, columns, opts \\ [])
  # Atalho para criar um índice único.

# E o esquema Distributor deve usar a macro belongs_to/3 para nos permitir chamar distributor.movies
# e procurar o filme associado a um distribuidor usando esta chave estrangeira.
# lib/company/distributor.ex
defmodule Company.Distributor do
  use Ecto.Schema

  schema "distributors" do
    field(:name, :string)
    belongs_to :movie, Company.Movie
    # belongs_to :movie, Company.Movie, references: :id
  end
end

# Em seguida, adicionaremos o relacionamento “has one” ao esquema Movie.
schema "movies" do
  ...
  has_one :distributor, Company.Distributor
  # has_one :distributor, Company.Distributor, references: :id
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
  schema "movies" do
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
    many_to_many :movies, Company.Movie, join_through: "movies_actors"
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

iex> alias Company.{Movie, Character, Repo, Actor}
# [Company.Movie, Company.Character, Company.Repo, Company.Actor]

# vamos criar um registro de filme
iex> movie_struct = %Movie{title: "Ready Player One", tagline: "Something about video games"}
# %Company.Movie{
#   __meta__: #Ecto.Schema.Metadata<:built, "movies">,
#   actors: #Ecto.Association.NotLoaded<association :actors is not loaded>,
#   characters: #Ecto.Association.NotLoaded<association :characters is not loaded>,
#   distributor: #Ecto.Association.NotLoaded<association :distributor is not loaded>,
#   id: nil,
#   tagline: "Something about video games",
#   title: "Ready Player One"
# }

iex> movie = Repo.insert!(movie_struct)
# iex> movie = Repo.get Movie, 1
# INSERT INTO "movies" ("tagline","title") VALUES ($1,$2) RETURNING "id" ["Something about video games", "Ready Player One"]
# %Company.Movie{
#   __meta__: #Ecto.Schema.Metadata<:loaded, "movies">,
#   actors: #Ecto.Association.NotLoaded<association :actors is not loaded>,
#   characters: #Ecto.Association.NotLoaded<association :characters is not loaded>,
#   distributor: #Ecto.Association.NotLoaded<association :distributor is not loaded>,
#   id: 5,
#   tagline: "Something about video games",
#   title: "Ready Player One"
# }

iex> character = Ecto.build_assoc(movie, :characters, %{name: "Wade Watts"})
# %Company.Character{
#   __meta__: #Ecto.Schema.Metadata<:built, "characters">,
#   id: nil,
#   movie: #Ecto.Association.NotLoaded<association :movie is not loaded>,
#   movie_id: 1,
#   name: "Wade Watts"
# }
iex> Repo.insert!(character)
# INSERT INTO "characters" ("movie_id","name") VALUES ($1,$2) RETURNING "id" [1, "Wade Watts"]
# %Company.Character{
#   __meta__: #Ecto.Schema.Metadata<:loaded, "characters">,
#   id: 1,
#   movie: #Ecto.Association.NotLoaded<association :movie is not loaded>,
#   movie_id: 1,
#   name: "Wade Watts"
# }
iex> distributor = Ecto.build_assoc(movie, :distributor, %{name: "Netflix"})
# %Company.Distributor{
#   __meta__: #Ecto.Schema.Metadata<:built, "distributors">,
#   id: nil,
#   movie: #Ecto.Association.NotLoaded<association :movie is not loaded>,
#   movie_id: 1,
#   name: "Netflix"
# }
iex> Repo.insert!(distributor)
# INSERT INTO "distributors" ("movie_id","name") VALUES ($1,$2) RETURNING "id" [1, "Netflix"]
# %Company.Distributor{
#   __meta__: #Ecto.Schema.Metadata<:loaded, "distributors">,
#   id: 1,
#   movie: #Ecto.Association.NotLoaded<association :movie is not loaded>,
#   movie_id: 1,
#   name: "Netflix"
# }

# Many to Many
# Salvando com Ecto.Changeset.put_assoc/4

# put_assoc(changeset, name, value, opts \\ [])
  # Coloca o dado entrada associação ou entradas como uma mudança no conjunto de alterações.

iex> actor_struct = %Actor{name: "Tyler Sheridan"}
# %Company.Actor{
#   __meta__: #Ecto.Schema.Metadata<:built, "actors">,
#   id: nil,
#   movies: #Ecto.Association.NotLoaded<association :movies is not loaded>,
#   name: "Tyler Sheridan"
# }
iex> actor = Repo.insert!(actor_struct)
# INSERT INTO "actors" ("name") VALUES ($1) RETURNING "id" ["Tyler Sheridan"]
# %Company.Actor{
#   __meta__: #Ecto.Schema.Metadata<:loaded, "actors">,
#   id: 1,
#   movies: #Ecto.Association.NotLoaded<association :movies is not loaded>,
#   name: "Tyler Sheridan"
# }

# trabalhar com Changesets, precisamos ter certeza de que nossa estrutura movie pré-carregou
# seus esquemas associados.

iex> movie = Repo.preload(movie, [:distributor, :characters, :actors])
# %Company.Movie{
#   __meta__: #Ecto.Schema.Metadata<:loaded, "movies">,
#   actors: [],
#   characters: [
#     %Company.Character{
#       __meta__: #Ecto.Schema.Metadata<:loaded, "characters">,
#       id: 1,
#       movie: #Ecto.Association.NotLoaded<association :movie is not loaded>,
#       movie_id: 1,
#       name: "Wade Watts"
#     }
#   ],
#   distributor: %Company.Distributor{
#     __meta__: #Ecto.Schema.Metadata<:loaded, "distributors">,
#     id: 1,
#     movie: #Ecto.Association.NotLoaded<association :movie is not loaded>,
#     movie_id: 1,
#     name: "Netflix"
#   },
#   id: 1,
#   tagline: "Something about video games",
#   title: "Ready Player One"
# }

# Em seguida, criaremos um conjunto de alterações para nosso registro de filme:
iex> movie_changeset = Ecto.Changeset.change(movie)
#Ecto.Changeset<action: nil, changes: %{}, errors: [], data: #Company.Movie<>, valid?: true>

# put_assoc (changeset, nome, valor, opts \\ [])
  # Coloca o dado entrada associação ou entradas como uma mudança no conjunto de alterações.
iex> movie_actors_changeset = movie_changeset |> Ecto.Changeset.put_assoc(:actors, [actor])
# #Ecto.Changeset<
#   action: nil,
#   changes: %{
#     actors: [
#       #Ecto.Changeset<action: :update, changes: %{}, errors: [],
#        data: #Company.Actor<>, valid?: true>
#     ]
#   },
#   errors: [],
#   data: #Company.Movie<>,
#   valid?: true
# >
# Isso nos dá um novo changeset, representando a seguinte mudança: adicione os atores nesta
# lista de atores ao registro de filme dado.

iex> Repo.update!(movie_actors_changeset)
# %Company.Movie{
#   __meta__: #Ecto.Schema.Metadata<:loaded, "movies">,
#   actors: [
#     %Company.Actor{
#       __meta__: #Ecto.Schema.Metadata<:loaded, "actors">,
#       id: 1,
#       movies: #Ecto.Association.NotLoaded<association :movies is not loaded>,
#       name: "Tyler Sheridan"
#     }
#   ],
#   characters: [
#     %Company.Character{
#       __meta__: #Ecto.Schema.Metadata<:loaded, "characters">,
#       id: 1,
#       movie: #Ecto.Association.NotLoaded<association :movie is not loaded>,
#       movie_id: 1,
#       name: "Wade Watts"
#     }
#   ],
#   distributor: %Company.Distributor{
#     __meta__: #Ecto.Schema.Metadata<:loaded, "distributors">,
#     id: 1,
#     movie: #Ecto.Association.NotLoaded<association :movie is not loaded>,
#     movie_id: 1,
#     name: "Netflix"
#   },
#   id: 1,
#   tagline: "Something about video games",
#   title: "Ready Player One"
# }
# atualizaremos os registros de filme e ator fornecidos usando nosso changeset mais recente
# isso nos dá um registro de filme com o novo ator apropriadamente associado e já pré-carregado para nós em movie.actors.

# Podemos usar essa mesma abordagem para criar um novo ator associado a determinado filme.
# Em vez de passar uma estrutura de ator salva para put_assoc/4,
# simplesmente passamos uma estrutura de ator que descreve um novo ator que queremos criar
iex> changeset = movie_changeset |> Ecto.Changeset.put_assoc(:actors, [%{name: "Gary"}])
# #Ecto.Changeset<
# action: nil,
# changes: %{
#   actors: [
#     #Ecto.Changeset<
#       action: :insert,
#       changes: %{name: "Gary"},
#       errors: [],
#       data: #Company.Actor<>,
#       valid?: true
#     >
#   ]
# },
# errors: [],
# data: #Company.Movie<>,
# valid?: true
# >

# um novo ator vai criado com um ID “2” e os atributos que atribuímos a ele.
iex> Repo.update!(changeset)
# %Company.Movie{
#   __meta__: #Ecto.Schema.Metadata<:loaded, "movies">,
#   actors: [
#     %Company.Actor{
#       __meta__: #Ecto.Schema.Metadata<:loaded, "actors">,
#       id: 2,
#       movies: #Ecto.Association.NotLoaded<association :movies is not loaded>,
#       name: "Gary"
#     }
#   ],
#   characters: [
#     %Company.Character{
#       __meta__: #Ecto.Schema.Metadata<:loaded, "characters">,
#       id: 1,
#       movie: #Ecto.Association.NotLoaded<association :movie is not loaded>,
#       movie_id: 1,
#       name: "Wade Watts"
#     }
#   ],
#   distributor: %Company.Distributor{
#     __meta__: #Ecto.Schema.Metadata<:loaded, "distributors">,
#     id: 1,
#     movie: #Ecto.Association.NotLoaded<association :movie is not loaded>,
#     movie_id: 1,
#     name: "Netflix"
#   },
#   id: 1,
#   tagline: "Something about video games",
#   title: "Ready Player One"
# }
