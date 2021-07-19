# NimblePublisher é um mecanismo de publicação simples baseado em um sistema de arquivos
# com suporte a Markdown e syntax highlighting.
# é uma biblioteca simples projetada para a publicação de conteúdo parseado de arquivos locais
# utilizando a sintaxe Markdown. "Um caso de uso típico seria a construção de um blog".

# Criando seu conteúdo
# Vamos construir nosso próprio blog. vamos utilizar uma aplicação Phoenix mas o Phoenix não é um requisito obrigatório.
# Como a NimblePublisher se encarrega apenas de parsear os arquivos locais,
# você pode utilizá-la em qualquer aplicação Elixir.

$ mix phx.new aula47_nimble_publisher --no-ecto

# em mix.exs
defp deps do
  [
    ...
    {:nimble_publisher, "~> 0.1.2"}
  ]
end

$ mix do deps.get, compile

$ cd assets
$ npm install
# ou
$ yarn

# Agora, vamos adicionar algumas postagens.
# Precisamos começar criando um diretório que irá conter nossas postagens.
# Vamos mantê-los organizados por ano neste formato: "/priv/posts/YEAR/MONTH-DAY-ID.md"

# criaremos dois posts
\priv\posts\2020\07-19-hello.md
\priv\posts\2021\07-19-elixir.md

# Uma postagem típica de blog será escrita na sintaxe Markdown,
# com uma seção de metadados no topo e o conteúdo abaixo separado por '---'

%{
  title: "title!",
  author: "author",
  tags: ~w(tag),
  description: "description"
}

---

body

# Crie suas próprias postagens. Apenas se certifique de seguir o formato acima para os metadados e conteúdo.

# em lib\aula47_nimble_publisher\blog\post.ex
defmodule Aula47NimblePublisher.Blog.Post do
  @enforce_keys [:id, :author, :title, :body, :description, :tags, :date]

  defstruct [:id, :author, :title, :body, :description, :tags, :date]

  def build(filename, attrs, body) do
    [year, month_day_id] =
      filename
      |> Path.rootname()
      |> Path.split()
      |> Enum.take(-2)

    [month, day, id] = String.split(month_day_id, "-", parts: 3)

    date = Date.from_iso8601!("#{year}-#{month}-#{day}")

    struct!(__MODULE__, [id: id, date: date, body: body] ++ Map.to_list(attrs))
  end
end

# O módulo 'Post' define a estrutura para os metadados e conteúdo,
# define também uma função build/3 com a lógica necessária para parsear o arquivo com o conteúdo da postagem.

# Com modulo 'Post' criado, podemos definir nosso contexto 'Blog' que irá utilizar a 'NimblePublisher'
# para parsear os arquivos locais em postagens.

# em lib\aula47_nimble_publisher\blog\blog.ex
defmodule Aula47NimblePublisher.Blog do
  alias Aula47NimblePublisher.Blog.Post

  use NimblePublisher,
    build: Post,
    from: Application.app_dir(:aula47_nimble_publisher, "priv/posts/**/*.md"),
    as: :posts,
    highlighters: [:makeup_elixir, :makeup_erlang]

  # A variável @posts é primeiramente definida por NimblePublisher em as:.
  # Vamos modificá-la ainda mais ordenando todas as postagens por data decrescente.
  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})

  # Vamos também recuperar todas as tags.
  @tags @posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  # E finalmente exportá-las.
  def all_posts, do: @posts
  def all_tags, do: @tags
end

# Como você pode perceber, o contexto 'Blog' utiliza a 'NimblePublisher' para construir a coleção de 'Post'
# a partir do diretório local indicado, utilizando o realce de sintaxe que desejamos usar.
# A 'NimblePublisher' irá criar a variável '@posts', que mais tarde processamos para ordenar
# as postagens em ordem decrescente por ':date' como normalmente queremos em um blog.
# Também definimos '@tags' a partir dos '@posts'.
# Finalmente, 'definimos all_posts/0' e 'all_tags/0' que retornarão apenas o que foi parseado respectivamente.

$ iex -S mix

iex> Aula47NimblePublisher.Blog.all_posts
# [
#   %Aula47NimblePublisher.Blog.Post{
#     author: "Jose Valim",
#     body: "<p>\nEssa ├® a postagem que voc├¬ estava esperando sobre o futuro do elixir.</p>\n",
#     date: ~D[2021-07-19],
#     description: "o futuro do elixir",
#     id: "elixir",
#     tags: ["elixir"],
#     title: "Elixir!"
#   },
#   %Aula47NimblePublisher.Blog.Post{
#     author: "Hercules",
#     body: "<p>\nSim, essa ├® <strong>a postagem</strong> que voc├¬ estava esperando.</p>\n",
#     date: ~D[2020-07-19],
#     description: "Nossa primeira postagem do blog est├í aqui",
#     id: "hello",
#     tags: ["hello"],
#     title: "Hello World!"
#   }
# ]

# Já temos todas as nossas postagens parseadas, com interpretação de Markdown
# e estamos prontas para seguir com as tags também!

# é importante perceber que a 'NimblePublisher' está cuidando de parsear os arquivos
# e construir a variável '@posts' com todos eles, e você parte daí para definir as funções de que precisa.
# Por exemplo, se precisarmos de uma função para obter as postagens recentes, podemos definir uma

# em lib\aula47_nimble_publisher\blog\blog.ex
def recent_posts(num \\ 5), do: Enum.take(all_posts(), num)

# Importante: evite injetar o atributo em várias funções,
# pois cada chamada fará uma cópia completa de todas as postagens.
# Por exemplo:
# NÃO faça isso:   'def recent_posts, do: Enum.take (@posts, 3)'
# FAÇA o seguinte: 'def recent_posts, do: Enum.take (all_posts(), 3)'


# Vamos precisar obter uma postagem por seu id e também listar todos as postagens de uma determinada tag.
# em lib\aula47_nimble_publisher\blog\blog.ex
...
defmodule NotFoundError do
  defexception [:message, plug_status: 404]
end

def get_post_by_id!(id) do
  Enum.find(all_posts(), &(&1.id == id)) ||
    raise NotFoundError, "post with id=#{id} not found"
end

def get_posts_by_tag!(tag) do
  case Enum.filter(all_posts(), &(tag in &1.tags)) do
    [] -> raise NotFoundError, "posts with tag=#{tag} not found"
    posts -> posts
  end
end
...

# Disponibilizando seu conteúdo
# Agora que já temos uma maneira de obter todas as nossas postagens e tags,
# disponibilizar significa apenas conectar as rotas, controllers, views e templates da forma usual.

# Rotas
# em \lib\aula47_nimble_publisher_web\router.ex
...
scope "/", Aula47NimblePublisherWeb do
  pipe_through :browser

  ...
  get "/blog", BlogController, :index
  get "/blog/:id", BlogController, :show
end
...

# Controller
# em \lib\aula47_nimble_publisher_web\controllers\blog_controller.ex
defmodule Aula47NimblePublisherWeb.BlogController do
  use Aula47NimblePublisherWeb, :controller

  alias Aula47NimblePublisher.Blog

  def index(conn, _params) do
    render(conn, "index.html", posts: Blog.all_posts())
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", post: Blog.get_post_by_id!(id))
  end
end

# View
# em \lib\aula47_nimble_publisher_web\views\blog_view.ex
defmodule Aula47NimblePublisherWeb.BlogView do
  use Aula47NimblePublisherWeb, :view
end

# Template
# criando os arquivos HTML para rederizar o conteúdo.
# em \lib\aula47_nimble_publisher_web\templates\blog\index.html.eex
<h1>Listing all posts</h1>

<%= for post <- @posts do %>
<div id="<%= post.id %>" style="margin-bottom: 3rem;">
<h2><%= link post.title, to: Routes.blog_path(@conn, :show, post)%></h2>

<p><time><%= post.date %></time> by <%= post.author %></p>

  <p>Tagged as <%= Enum.join(post.tags, ", ") %></p>

  <%= raw post.description %>
  </div>
  <% end %>

# em \lib\aula47_nimble_publisher_web\templates\blog\show.html.eex
<%= link "← All posts", to: Routes.blog_path(@conn, :index)%>

<h1><%= @post.title %></h1>

<p><time><%= @post.date %></time> by <%= @post.author %></p>

<p>Tagged as <%= Enum.join(@post.tags, ", ") %></p>

<%= raw @post.body %>

# Tudo pronto para seguir! Abra o seu servidor web
$ iex -S mix phx.server
# e visite http://localhost:4000/blog para conferir seu novo blog em ação!
