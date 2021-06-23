defmodule Aula42AuthMeWeb.PageController do
  use Aula42AuthMeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def protected(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "protected.html", current_user: user)
  end
end
