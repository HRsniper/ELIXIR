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

# Plug.Router
# Para a maioria das aplicações, como um site web ou uma API REST, você irá querer um router para orquestrar
# as requisições de diferentes paths e verbos HTTP, para diferentes manipuladores.
# Plug fornece um router para fazer isso.

# em lib/aula36_plug/router.ex
defmodule Aula36Plug.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end


# plug (plug, opts \\ []) (macro)
  # Um macro que armazena um novo plug. opts serão passados e não serão alterados para o novo plugue.
  # Este macro não adiciona nenhuma proteção ao adicionar o novo plugue ao pipeline;
  # para adicionar plugs com protetores, consulte compile/3.

# get(path, options, contents \\ [])(macro)
  # Despacha para o caminho apenas se a solicitação for uma solicitação GET.

# match(path, options, contents \\ [])(macro)
  # API principal para definir rotas.
  # Ele aceita uma expressão que representa o caminho e muitas opções que permitem a configuração da correspondência.
  # A rota pode ser despachada para um corpo de função ou um módulo de Plug.

# Incluímos alguns macros através de ´use Plug.Router´,
# e em seguida, configuramos dois Plugs nativos: :match e :dispatch.
# definimos duas rotas, uma para mapear requisições GET para a raiz ("/")
# e a segunda para mapear todos as outras requisições, e então retornar um 404 com a mensagem.

# Os métodos HTTP suportados são get, post, put, patch, delete e options.

# em lib/aula36_plug/application.ex, precisamos adicionar o Aula36Plug.Router na árvore de supervisores.
# então Trocamos o Aula36Plug.MyPlug para o router Aula36Plug.Router.
children = [
  {Plug.Cowboy, scheme: :http, plug: Aula36Plug.Router, options: [port: 8080]}
]

# para o servidor se estive rodando
# inicie o servidor
$ mix run --no-halt

http://127.0.0.1:8080 vai retornar ´Welcome´ no body.
http://localhost:8080/wet45ymy, ou qualquer outro path. vai retornar ´Oops!´ com uma resposta 404.


# Adicionando outro Plug
# É comum usar mais de um plug em uma única aplicação web, cada uma tendo sua própria responsabilidade.
#   exemplo:
#   - um plug que lida com roteamento
#   - um plug que valida as requisições recebidas
#   - um plug que autentica as requisições

# Vamos criar um Plug para verificar se a requisição tem um conjunto de parâmetros necessários.
# Ao implementar a nossa validação em um Plug, podemos ter a certeza de que apenas as requisições válidas
# serão processadas pela nossa aplicação.
# Vamos esperar que o nosso Plug seja inicializado com duas opções: :paths e :fields.
# Estes irão representar os caminhos que aplicamos nossa lógica, e onde os campos são exigidos.

# Note: Plugs são aplicados a todas as requisições, e é por isso que nós filtraremos as requisições
# e aplicaremos nossa lógica para apenas um subconjunto delas.
# Para ignorar uma requisição simplesmente passamos a conexão através do mesmo.

# em lib/example/plug/verify_request.ex
defmodule Aula36Plug.Plug.VerifyRequest do
  defmodule IncompleteRequestError do
    @moduledoc """
    Levanta um erro quando um campo obrigatório está faltando.
    """

    defexception message: ""
  end

  def init(options), do: options

  def call(%Plug.Conn{request_path: path} = conn, opts) do
    if path in opts[:paths], do: verify_request!(conn.params, opts[:fields])
    conn
  end

  defp verify_request!(params, fields) do
    verified =
      params
      |> Map.keys()
      |> contains_fields?(fields)

    unless verified, do: raise(IncompleteRequestError)
  end

  defp contains_fields?(keys, fields), do: Enum.all?(fields, &(&1 in keys))
end

# A primeira coisa a ser notada é que definimos uma nova exceção IncompleteRequestError
# a qual iremos acionar no caso de uma requisição inválida.

# A segunda parte do nosso Plug é a função call/2. Este é o lugar onde nós lidamos quando aplicar
# ou não nossa lógica de verificação. Somente quando o path da requisição está contido em nossa
# opção :paths iremos chamar verify_request!/2.

# A última parte do nosso Plug é a função privada verify_request!/2 no qual verifica
# se os campos requeridos :fields estão todos presentes.
# No caso em que algum dos campos requeridos estiver em falta, nós acionamos IncompleteRequestError.

# Configuramos o nosso Plug para verificar se todas as requisições para /upload incluem tanto "content" quanto "mimetype". Só então o código da rota irá ser executado.
# em lib/example/router.ex
defmodule Aula36Plug.Router do
  use Plug.Router
  alias Aula36Plug.Plug.VerifyRequest

  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug VerifyRequest, fields: ["content", "mimetype"], paths: ["/upload"]
  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  get "/upload" do
    send_resp(conn, 201, "Uploaded")
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end

# Plug.Parsers (behaviour)
# Um plugue para analisar o corpo da solicitação.
# Ele invoca uma lista de `: parsers`, que são ativados com base no tipo de conteúdo da solicitação.
# Os analisadores customizados também são suportados definindo um módulo que implementa o comportamento
# definido por este módulo.

# Nós automaticamente invocamos VerifyRequest.init(fields: ["content", "mimetype"], paths: ["/upload"]).
# Isso por sua vez passa as opções recebidas para a função VerifyRequest.call(conn, opts).

$ mix run --no-halt

# quando acessado http://127.0.0.1:8080/upload em um navegador, a página simplesmente não está funcionando.
# Você verá apenas uma página de erro padrão fornecida pelo navegador.

# Assim que adicionarmos os parâmetros obrigatórios por acessar
# http://localhost:8080/upload?content=thing1&mimetype=thing2.
# Agora nós devemos ver nossa mensagem ‘Uploaded’.

# Configurando a porta HTTP
# Quando definimos a aplicação e o módulo Aula36Plug, a porta HTTP foi definida diretamente no código do módulo.
# pela arvore de supervisão.
# É considerado uma boa prática, deixar a porta configurável usando um arquivo de configuração.

# em config/config.exs
use Mix.Config

config :aula36_plug, cowboy_port: 8080

# em lib\aula36_plug\application.ex
children = [
  {Plug.Cowboy, scheme: :http, plug: Aula36Plug.Router, options: [port: cowboy_port()]}
]
...
defp cowboy_port, do: Application.get_env(:aula36_plug, :cowboy_port, 8080)

# O terceiro argumento do Application.get_env é um valor padrão para quando a variável de configuração não estiver definida.

$ mix run --no-halt
# em http://localhost:4000/ era retorna 'Welcome'

# Testando Plugs
# Testes em Plugs são bastante simples, graças ao Plug.Test, que inclui uma série de funções convenientes
# para fazer o teste ser algo fácil.

# em test/aula36_plug/router_test.exs
defmodule Aula36Plug.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias Aula36Plug.Router

  @content "<html><body>Hi!</body></html>"
  @mimetype "text/html"

  @opts Router.init([])

  test "returns welcome" do
    conn =
      :get
      |> conn("/", "")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "returns uploaded" do
    conn =
      :get
      |> conn("/upload?content=#{@content}&mimetype=#{@mimetype}")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 201
  end

  test "returns 404" do
    conn =
      :get
      |> conn("/missing", "")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end

# conn(method, path, params_or_body \\ nil)
# Cria uma conexão de teste.
# O método e o caminho da solicitação são argumentos obrigatórios.
# method pode ser qualquer valor que implemente to_string/1
# e será convertido e normalizado corretamente (por exemplo, :get ou "post").

$ mix test test/router_test.exs
# 18:56:21.769 [info]  Starting application...
# ...
# Finished in 0.1 seconds
# 3 tests, 0 failures

# para testar todos *_test.exs em /test
$ mix test

# Plug.ErrorHandler
# Notamos anteriormente que quando nós acessamos http://localhost:4000/upload sem os parâmetros esperados,
# não recebemos uma página de erro amigável ou um status HTTP sensato,
# apenas a página de erro padrão do nosso navegador com um 500 Internal Server Error ou HTTP ERROR 500.

# Plug.ErrorHandler é um módulo a ser usado em seus plugs existentes para fornecer tratamento de erros.
# Uma vez que este módulo é usado, um callback chamado `handle_errors/2` deve ser definido em seu plug.
# Este retorno de chamada receberá a conexão já atualizada com um código de status adequado para a exceção
# fornecida. O segundo argumento é um mapa contendo:
# - o tipo de exceção :kind (:throw, :error ou :exit).
# - o motivo :reason (uma exceção para erros ou um termo para outros).
# - o rastreamento de pilha :stacktrace Depois que o retorno de chamada é invocado, o erro é gerado novamente.
  # handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) callback

# Observe também que essas páginas serão exibidas na produção.
# Se você estiver procurando por tratamento de erros para ajudar durante o desenvolvimento,
#  considere o uso de Plug.Debugger.

# em lib\aula36_plug\router.ex
use Plug.ErrorHandler
...
def handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
  IO.inspect(kind, label: :kind)
  IO.inspect(reason, label: :reason)
  IO.inspect(stack, label: :stack)
  send_resp(conn, conn.status, "Something went wrong")
end

$ mix run --no-halt

# http://localhost:4000/upload
# no terminal:
  # kind: :error
  # reason: %Aula36Plug.Plug.VerifyRequest.IncompleteRequestError{message: ""}
  # stack: [
  #   {Aula36Plug.Plug.VerifyRequest, :verify_request!, 2,
  #   [file: 'lib/aula36_plug/plug/verify_request.ex', line: 25]},
  #   {Aula36Plug.Plug.VerifyRequest, :call, 2,
  #   [file: 'lib/aula36_plug/plug/verify_request.ex', line: 15]},
  #   {Aula36Plug.Router, :plug_builder_call, 2,
  #   [file: 'lib/aula36_plug/router.ex', line: 1]},
  #   {Aula36Plug.Router, :call, 2, [file: 'lib/plug/error_handler.ex', line: 65]},
  #   {Plug.Cowboy.Handler, :init, 2,
  #   [file: 'lib/plug/cowboy/handler.ex', line: 12]},
  #   {:cowboy_handler, :execute, 2,
  #   [
  #     file: 'd:/HR-DEV/ELIXIR/aula36_plug/deps/cowboy/src/cowboy_handler.erl',
  #     line: 37
  #   ]},
  #   {:cowboy_stream_h, :execute, 3,
  #   [
  #     file: 'd:/HR-DEV/ELIXIR/aula36_plug/deps/cowboy/src/cowboy_stream_h.erl',
  #     line: 300
  #   ]},
  #   {:cowboy_stream_h, :request_process, 3,
  #   [
  #     file: 'd:/HR-DEV/ELIXIR/aula36_plug/deps/cowboy/src/cowboy_stream_h.erl',
  #     line: 291
  #   ]}
  # ]

# no navegador:
  # Something went wrong

# No momento, ainda estamos enviando um 500 Internal Server Error.
# abre DevTools do seu navegador em console: GET http://localhost:4000/upload 500 (Internal Server Error)
# Podemos personalizar o código de status adicionando o campo :plug_status à nossa exceção.
# em lib/aula36_plug/plug/verify_request.ex
defmodule IncompleteRequestError do
  @moduledoc """
  Levanta um erro quando um campo obrigatório está faltando.
  """

  defexception message: "", plug_status: 400
end

# e agora você receberá um 400 Bad Request.
# abre DevTools do seu navegador em console: GET http://localhost:4000/upload 400 (Bad Request)


# Existem inúmeros Plugs disponíveis prontos para uso.
# A lista completa pode ser encontrada na documentação do Plug: https://github.com/elixir-plug/plug#available-plugs
