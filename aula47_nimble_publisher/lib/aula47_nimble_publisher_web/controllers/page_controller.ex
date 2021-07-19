defmodule Aula47NimblePublisherWeb.PageController do
  use Aula47NimblePublisherWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
