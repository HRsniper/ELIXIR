defmodule Aula46DistilleryPhoenixWeb.Router do
  use Aula46DistilleryPhoenixWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Aula46DistilleryPhoenixWeb do
    pipe_through :api
  end
end
