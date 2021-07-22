defmodule Aula48MoxWeb.Router do
  use Aula48MoxWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Aula48MoxWeb do
    pipe_through :api
  end
end
