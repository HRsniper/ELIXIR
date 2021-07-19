defmodule Aula47NimblePublisher.Blog do
  alias Aula47NimblePublisher.Blog.Post

  use NimblePublisher,
    build: Post,
    from: Application.app_dir(:aula47_nimble_publisher, "priv/posts/**/*.md"),
    as: :posts,
    highlighters: [:makeup_elixir, :makeup_erlang]

  # A variável @posts é primeiramente definida por NimblePublisher.
  # Vamos modificá-la ainda mais ordenando todas as postagens por data decrescente.
  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})

  # Vamos também recuperar todas as tags.
  @tags @posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  # E finalmente exportá-las.
  def all_posts, do: @posts
  def all_tags, do: @tags
  def recent_posts(num \\ 5), do: Enum.take(all_posts(), num)

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
end
