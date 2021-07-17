# Distillery é um gerenciador de releases escrito em Elixir puro.
# Ele permite que você produza releases que podem ser deployed em outros lugares com pouca ou nenhuma configuração.

# Uma release é um pacote contendo o seu código Erlang/Elixir compilado BEAM/bytecode.
# Ela também provê quaisquer scripts necessários para rodar a sua aplicação.

# Uma release irá conter o seguinte arquivos:
# uma pasta /bin - Esta contém um script que é o ponto de início para rodar a sua aplicação inteira.
# uma pasta /lib - Esta contém o bytecode compilado da aplicação junto com quaisquer dependências.
# uma pasta /releases - Esta contém metadados sobre a release assim como também hooks e comandos customizados.
# Um /erts-VERSION - Este contém o runtime do Erlang que irá permitir que uma máquina execute
  # a sua aplicação sem necessitar ter o Erlang ou Elixir instalados.

$ mix new aula46_distillery

# em mix.exs
defp deps do
  [{:distillery, "~> 2.1"}]
end

$ mix do deps.get, compile


# Construindo a sua release
$ mix release.init
# Este comando gera um diretório 'rel' com alguns arquivos de configuração nele.
# Para gerar uma release
$ mix release
# Quando a release for produzida, você deve ver algumas instruções no seu terminal:
# Release created at _build/dev/rel/aula46_distillery!
#     # To start your system
#     _build/dev/rel/aula46_distillery/bin/aula46_distillery start
# Once the release is running:
#     # To connect to it remotely
#     _build/dev/rel/aula46_distillery/bin/aula46_distillery remote
#     # To stop it gracefully (you may also send SIGINT/SIGTERM)
#     _build/dev/rel/aula46_distillery/bin/aula46_distillery stop
# To list all commands:
#     _build/dev/rel/aula46_distillery/bin/aula46_distillery

$ _build/dev/rel/aula46_distillery/bin/aula46_distillery
# Usage: aula46_distillery.bat COMMAND [ARGS]
# The known commands are:
#    start        Starts the system
#    start_iex    Starts the system with IEx attached
#    install      Installs this system as a Windows service
#    eval "EXPR"  Executes the given expression on a new, non-booted system
#    rpc "EXPR"   Executes the given expression remotely on the running system
#    remote       Connects to the running system via a remote shell
#    restart      Restarts the running system via a remote command
#    stop         Stops the running system via a remote command
#    pid          Prints the operating system PID of the running system via a remote command
#    version      Prints the release name and version to be booted

# Utilizando Distillery com o Phoenix

$ mix phx.new aula46_distillery_phoenix --no-webpack --no-html --no-gettext --no-dashboard

# em mix.exs
defp deps do
  [
    ...
    {:distillery, "~> 2.1"}
  ]
end

$ mix do deps.get, compile

# Distillery com o Phoenix há alguns passos extras que você precisa seguir disto de funcionar.
# em config/prod.exs
# altere o endpoint disto:
config :aula46_distillery_phoenix, Aula46DistilleryPhoenixWeb.Endpoint,
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

# para esse endpoint:
config :aula46_distillery_phoenix, Aula46DistilleryPhoenixWeb.Endpoint,
  http: [port: {:system, "PORT"} || 80],
  url: [host: "localhost", port: {:system, "PORT"} || 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Application.spec(:aula46_distillery_phoenix, :vsn)

# nós fizemos as seguintes alterações:
# server - inicia o endpoint HTTP da aplicação Cowboy no início do aplicação
# root - define a raiz da aplicação que é onde os arquivos estáticos são servidos
# version - quebra o cache da aplicação quando a versão da mesma sofre um hot upgrade
# port - alterar a porta se for setada uma variável de ambiente permitindo que passamos
# o número da porta quando estivermos iniciando a aplicação. Quando iniciamos a aplicação,
# podemos suprir a porta executando 'PORT=4001 _build/prod/rel/book_app/bin/book_app foreground'

# vamos configurar o banco de dados para se conectar em produção
# em config/prod.secret.exs
...
database_url =
  "ecto://postgres:postgres@localhost/aula46_distillery_phoenix_prod" ||
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """
...
secret_key_base =
  "6PDPK9LARAAoA/9yQ10s8HWJULlZUX6BEO8ixHc+yMBvjk+Hl5vRNzRfDjMTW0LG" ||
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

$ MIX_ENV=prod mix ecto.create
# ou
$ mix ecto.create --env=prod
# The database for Aula46DistilleryPhoenix.Repo has been created

$ mix distillery.init

$ MIX_ENV=prod mix distillery.release
# ou
$ mix distillery.release --env=prod

$ _build/dev/rel/aula46_distillery_phoenix/bin/aula46_distillery_phoenix.bat console

$ _build/dev/rel/aula46_distillery_phoenix/bin/aula46_distillery_phoenix.bat foreground
