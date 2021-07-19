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
