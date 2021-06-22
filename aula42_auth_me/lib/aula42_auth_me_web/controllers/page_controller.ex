defmodule Aula42AuthMeWeb.PageController do
  use Aula42AuthMeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
