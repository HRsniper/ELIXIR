defmodule Aula42AuthMeWeb.Router do
  use Aula42AuthMeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Nosso pipeline implementa 'maybe authenticated'.
  # Usaremos o ':ensure_auth' abaixo para quando precisarmos ter certeza de que alguém está conectado.
  pipeline :auth do
    plug Aula42AuthMe.UserManager.Pipeline
  end

  # Usamos ':ensure_auth' para falhar se não houver ninguém conectado.
  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  # rota de talvez logado em espoco
  scope "/", Aula42AuthMeWeb do
    pipe_through [:browser, :auth]

    get "/", PageController, :index

    get "/login", SessionController, :new
    post "/login", SessionController, :login
    get "/logout", SessionController, :logout
  end

  # Definitivamente logo em escopo
  scope "/", Aula42AuthMeWeb do
    pipe_through [:browser, :auth, :ensure_auth]

    get "/protected", PageController, :protected
  end

  # Other scopes may use custom stacks.
  # scope "/api", Aula42AuthMeWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: Aula42AuthMeWeb.Telemetry
    end
  end
end
