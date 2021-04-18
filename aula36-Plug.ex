# Plug fornece uma especificação para componentes de aplicação web e adaptadores para servidores web.
# Mesmo não fazendo parte do núcleo de Elixir, Plug é um projeto oficial de Elixir.

# vamos construir um simples servidor HTTP do zero usando a biblioteca em Elixir PlugCowboy.
# Cowboy2 é um simples servidor HTTP para o Erlang e Plug vai nos disponibilizar um “connection adapter”
# para esse servidor web. também vamos fazer as rotas do Plug e como usar vários plugs em uma única aplicação web.

# Nós precisamos que nossa aplicação Elixir inclua uma árvore de supervisão porque nós vamos usar um Supervisor
# para iniciar e rodar nosso servidor Cowboy2.

$ mix new aula36_plug --sup
$ cd aula36_plug/

# Para usar o Plug como uma “adapter interface” para o servidor web Cowboy2,
# nós precisamos instalar o pacote plug_cowboy.

# em mix.exs:
def deps do
  [
    {:plug_cowboy, "~> 2.4"}
  ]
end

$ mix deps.get


# A especificação do Plug
# Existem dois tipos de plugues: plugues de função e plugues de módulo.
# Plugues de função
  # Um plugue de função é qualquer função que recebe uma conexão e um conjunto de opções
  # e retorna uma conexão. Sua assinatura de tipo deve ser: (Plug.Conn.t, Plug.opts) :: Plug.Conn.t
# Plugues de módulo
#   Um plugue de módulo é uma extensão do plugue de função. É um módulo que deve exportar:
  # - uma função call/2 com a assinatura: (Plug.Conn.t, Plug.opts) :: Plug.Conn.t
  # - uma função init/1 que pega um conjunto de opções e o inicializa.
# O resultado retornado por ´init/1´ é passado como segundo argumento para ´call/2´.
# Note que ´init/1´ pode ser chamado durante a compilação e, como tal, não deve retornar pids,
# portas ou valores que são específicos para o tempo de execução.
# A API esperada por um plug de módulo é definida como um comportamento pelo módulo de Plug: ´import Plug.Conn´

# call(conn, opts) Callback
# init(opts) Callback

# em lib\aula36_plug\my-plug.ex
defmodule Aula36Plug.MyPlug do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello world")
  end
end

# put_resp_content_type(conn, content_type, charset \\ "utf-8")
  # Define o valor do cabeçalho de resposta "content-type" levando em consideração o conjunto de caracteres (charset).
# send_resp(conn)
  # Envia uma resposta ao cliente.
# send_resp(conn, status, body)
  # Envia uma resposta com o status e o corpo fornecidos.

# A função init/1 vai ser inalada e chamada pela árvore de supervisores,
# O valor retornado do init/1 será eventualmente passado para call/2 como segundo argumento.
# A função call/2 é chamada para cada nova requisição recebida pelo servidor web Cowboy.
# Ela recebe um %Plug.Conn{} struct como seu primeiro argumento,
# e é esperado que isto retorne um struct %Plug.Conn{}.


# Configurando o módulo do projeto
# Nós precisamos dizer para a nossa aplicação iniciar e supervisionar o servidor web Cowboy2
# quando a aplicação estiver de pé.
# Nós vamos fazer isso com a função Plug.Cowboy.child_spec/1.
# child_spec (opts)
  # Uma função para iniciar um servidor Cowboy2 sob supervisores Elixir v1.5+.
  # - essa função espera três opções:
    # :scheme - HTTP ou HTTPS (:http, :https)
    # :plug - O módulo plug que deve ser usado como a interface para o servidor web.
      # Você pode especificar o nome do módulo, como Aula36Plug.MyPlug,
      # ou uma tupla com o nome do módulo e opções {Aula36Plug.MyPlug, plug_opts},
      # onde plug_opts é passada para a função init/1 do seu módulo plug.
    # :options - As opções do servidor. Deve ser incluído o número da porta em que você deseja
      # que servidor escute por requisições.

# em lib\aula36_plug\application.ex
children = [
  {Plug.Cowboy, scheme: :http, plug: Aula36Plug.MyPlug, options: [port: 8080]}
]

# Note: Nós não temos que chamar child_spec/1 aqui, essa função vai ser chamada pelo supervisor iniciando o processo.
# Nós simplesmente passamos uma tupla com o módulo que nós queremos a child spec e as três opções necessárias.

# Isso inicia o servidor Cowboy2 debaixo da árvore de supervisão de nossa app.
# Ele inicia o Cowboy2 debaixo do esquema HTTP na porta 8080,
# especificando o plug, Aula36Plug.MyPlug, como a interface para qualquer requisições web recebidas.

# A aplicação esta pronta para rodar,vamos enviar algumas requisições!
# nós geramos nosso OTP app com a parâmetro --sup, nossa aplicação Aula36Plug vai iniciar automaticamente
# graças a função ´application´.
# em mix.exs
def application do
  [
    extra_applications: [:logger],
    mod: {Aula36Plug.Application, []}
  ]
end

# vamos coloca um logger paa ver no console que a aplicação foi iniciada
# em lib\aula36_plug\application.ex
  ...
  require Logger
  ...
  Logger.info("Starting application...") # <- Logger

  Supervisor.start_link(children, opts)
  ...

# iniciando o servidor, --no-halt : não para o sistema após executar o comando
$ mix run --no-halt
# Quando a compilação estiver terminado, ira aparecer ´[info] Starting application...´,
# abra o navegador em ´127.0.0.1:8080´ ou ´http://localhost:8080/´.

# o body do site sera
Hello World!
