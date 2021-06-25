# Ao testar nossas aplicações, muitas vezes precisamos fazer chamadas a serviços externos.
# Podemos até mesmo querer simular diferentes situações como erros inesperados do servidor.
# Tratar isso de modo eficiente não é fácil no Elixir sem uma pequena ajuda.

# Com bypass nos ajudar rapidamente e tratar facilmente essas chamadas em nossos testes.

# O que é Bypass? Bypass é descrito como “uma forma rápida de criar um plug customizado que
# pode substituir um servidor HTTP real para retornar respostas previamente definidas
# para requisições de clientes.
# O que isso significa? Internamente, Bypass é uma aplicação OTP que atua como um servidor externo
# escutando e respondendo a requisições. Com respostas pré-definidas nós podemos testar
# qualquer número de possibilidades como interrupções inesperadas de serviço e erros,
# tudo sem fazer uma única chamada externa.

# Usando Bypass
# Para melhor ilustrar as funcionalidades do Bypass vamos construir uma aplicação utilitária
# simples para testar o 'ping' de uma lista de domínios e garantir que eles estão online.
# Para fazer isso vamos construir um novo projeto supervisor e um GenServer para verificar
# os domínios em um intervalo configurável. Aproveitando ByPass em nossos testes poderemos
# verificar se nossa aplicação funcionará em muitos cenários diferentes.

$ mix new aula45_bypass --sup

# em mix.exs
...
defp deps do
  [
    {:httpoison, "~> 1.8"},
    {:bypass, "~> 2.1"}
  ]
end
...

# Vamos começar criando um novo módulo que tratará de fazer as requisições para nossos domínios.
# Com 'HTTPoison' vamos criar uma função, 'ping/1', que recebe uma URL e retorna {:ok, body}
# para uma requisição HTTP 200 e {:error, reason} para todos os outros.

# em lib\aula45_bypass\health_check.ex
defmodule Aula45Bypass.HealthCheck do
  def ping(urls) when is_list(urls), do: Enum.map(urls, &ping/1)

  def ping(url) do
    url
    |> HTTPoison.get()
    |> response()
  end

  defp response({:ok, %{status_code: 200, body: body}}), do: {:ok, body}
  defp response({:ok, %{status_code: status_code}}), do: {:error, "HTTP Status #{status_code}"}
  defp response({:error, %{reason: reason}}), do: {:error, reason}
end

$ mix do deps.get, compile

# Você vai notar que não estamos fazendo um GenServer e isso é por uma boa razão:
# Separando nossa funcionalidade (e preocupações) do GenServer, podemos testar nosso
# código sem o obstáculo adicional de concorrência.

# Com nosso código pronto, precisamos começar os testes. Antes de usarmos Bypass precisamos garantir que ele está rodando.
# em test/test_helper.exs
ExUnit.start()
Application.ensure_all_started(:bypass)

# Agora que sabemos que Bypass vai rodar durante nossos testes.
# em test/aula45_bypass/health_check_test.exs
defmodule Aula45Bypass.HealthCheckTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end
end

# vamos terminar nossa configuração. Para preparar o Bypass para aceitar chamadas precisamos abrir a conexão
# com 'Bypass.open/1', que pode ser feito na nossa callback de configuração do test.
# também podemos trocar a porta padrao do bypass podemos chamar 'Bypass.open/1',
# com a opção :port e um valor como 'Bypass.open(port: 1337)'.

# Agora estamos prontos para colocar o Bypass para trabalhar. Vamos começar uma chamada bem sucedida primeiramente.
# em test/aula45_bypass/health_check_test.exs
...
alias Aula45Bypass.HealthCheck
...
test "request with HTTP 200 response", %{bypass: bypass} do
  Bypass.expect(bypass, fn conn ->
    Plug.Conn.resp(conn, 200, "Bypass Response")
  end)

  assert {:ok, "Bypass Response"} = HealthCheck.ping("http://localhost:#{bypass.port}")
end
...

# 'Bypass.expect/2' recebe nossa conexão Bypass e uma função de aridade simples que se espere que
# modifique a conexão e a retorne, isso também é uma oportunidade para fazer afirmações na chamada
# para verificar se ela está conforme esperado.

$ mix test
# ...
# Finished in 0.4 seconds (0.00s async, 0.4s sync)
# 1 doctest, 2 tests, 0 failures
# Randomized with seed 530000

# Vamos atualizar a url do nosso teste para incluir /ping e afirmar (assert) o caminho da chamada e o método HTTP.
# em test/aula45_bypass/health_check_test.exs
...
test "request with HTTP 200 response", %{bypass: bypass} do
  Bypass.expect(bypass, fn conn ->
    assert "GET" == conn.method
    assert "/ping" == conn.request_path
    Plug.Conn.resp(conn, 200, "Bypass Response")
  end)

  assert {:ok, "Bypass Response"} = HealthCheck.ping("http://localhost:#{bypass.port}/ping")
end
...

# A última parte do nosso teste que usamos 'HealthCheck.ping/1' e afirmamos a resposta está conforme esperado,
# mas do que se trata o 'bypass.port'? Bypass está realmente escutando uma porta local
# e interceptando as requisições, onde estamos usando bypass.port para retornar a porta padrão
# uma vez que não definimos uma no 'Bypass.open/1'.

$ mix test
# ...
# Finished in 0.4 seconds (0.00s async, 0.4s sync)
# 1 doctest, 2 tests, 0 failures
# Randomized with seed 842000

# agora adicionamos casos de teste para erros. Podemos começar com um teste muito parecido com nosso primeiro,
# com algumas pequenas mudanças: retornando 500 como código de status e afirmando que a tupla {:error, reason} é retornada.
# em test/aula45_bypass/health_check_test.exs
...
test "request with HTTP 500 response", %{bypass: bypass} do
  Bypass.expect(bypass, fn conn ->
    Plug.Conn.resp(conn, 500, "Bypass Response 500")
  end)

  assert {:error, "HTTP Status 500"} = HealthCheck.ping("http://localhost:#{bypass.port}")
end
...

# Não há nada de especial para este caso de teste, então vamos passar para o próximo:
# interrupções inesperadas do servidor, estas são as chamadas com as quais estamos mais preocupados.
# Para fazer isso usaremos 'Bypass.down/1' ao invés 'Bypass.expect/2' para desligar a conexão.
# em test/aula45_bypass/health_check_test.exs
...
test "request with unexpected outage", %{bypass: bypass} do
  Bypass.down(bypass)

  assert {:error, :econnrefused} = HealthCheck.ping("http://localhost:#{bypass.port}")
end
...

# Se executarmos nossos testes veremos tudo passando conforme esperado! Com nosso módulo HealthCheck testado,
# podemos seguir em frente e testá-lo juntamente como nosso scheduler baseado no GenServer.

# Vários hosts externos
# Para nosso projeto manteremos as estruturas do scheduler e usaremos 'Process.send_after/3'
# para alimentar nossas verificações reincidentes. # modulo process (https://hexdocs.pm/elixir/Process.html)
# Nosso scheduler necessita de três opções: a coleção de sites, o intervalo de nossas verificações,
# e o módulo que implementa ping/1.

# Ao passar no nosso módulo, separamos nossa funcionalidade e o nosso GenServer,
# permitindo-nos testar cada um em isolamento.

# em lib\aula45_bypass\scheduler.ex
defmodule Aula45Bypass.Scheduler do

  require Logger
  alias Aula45Bypass.HealthCheck

  def init(opts) do
    sites = Keyword.fetch!(opts, :sites)
    interval = Keyword.fetch!(opts, :interval)
    health_check = Keyword.get(opts, :health_check, HealthCheck)

    Process.send_after(self(), :check, interval)

    {:ok, {health_check, sites}}
  end
end

# Agora precisamos definir a função 'handle_info/2' para a mensagem :check enviada para 'send_after/2'.
# Para manter as coisas simples vamos passar nossos sites para a 'HealthCheck.ping/1'
# e logar nossos resultados com 'Logger.info' ou 'Logger.error' no caso de erros.

# em lib\aula45_bypass\scheduler.ex
...
def handle_info(:check, {health_check, sites}) do
  sites
  |> health_check.ping()
  |> Enum.each(&report/1)

  {:noreply, {health_check, sites}}
end

defp report({:ok, body}), do: Logger.info(body)

defp report({:error, reason}) do
  reason
  |> to_string()
  |> Logger.error()
end
...

# Conforme discutido, passamos nossos sites para a 'HealthCheck.ping/1' então iteramos os resultados com 'Enum.each/2'
# aplicando nossa função 'report/1' em cada uma delas. Com essas funções nosso scheduler está pronto
# e podemos nos concentrar em testá-lo.
# em test/aula45_bypass/scheduler_test.exs
defmodule Aula45Bypass.SchedulerTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Aula45Bypass.Scheduler

  defmodule TestCheck do
    def ping(_sites), do: [{:ok, "pong"}, {:error, "HTTP Status 404"}]
  end

  test "health checks are run and results logged" do
    opts = [health_check: TestCheck, interval: 1, sites: ["http://example.com", "http://example.org"]]

    output =
      capture_log(fn ->
        {:ok, _pid} = GenServer.start_link(Scheduler, opts)
        :timer.sleep(10)
      end)

    assert output =~ "pong"
    assert output =~ "HTTP Status 404"
  end
end

# Confiamos em uma implementação de teste de nossos health checks com TestCheck juntamente
# com CaptureLog.capture_log/1 para afirmar que as mensagens apropriadas são logadas.

$ mix test

# Agora trabalhamos nos módulos Scheduler e HealthCheck, vamos escrever um teste de integração
# para verificar tudo funcionando junto. Precisaremos do Bypass para este teste
# e teremos que tratar múltiplas chamadas com Bypass por teste.

# Lembra do bypass.port? Quando precisamos simular múltiplos sites, a opção :port vem a calhar.
# Como você provavelmente adivinhou, podemos criar múltiplas conexões Bypass cada uma com uma porta diferente,
# estas que simularão sites independentes.

# vamos atualizar nosso arquivo test\aula45_bypass_test.exs
defmodule Aula45BypassTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Aula45Bypass.Scheduler

  test "sites are checked and results logged" do
    bypass_one = Bypass.open(port: 1234)
    bypass_two = Bypass.open(port: 1337)

    Bypass.expect(bypass_one, fn conn ->
      Plug.Conn.resp(conn, 500, "Server Error")
    end)

    Bypass.expect(bypass_two, fn conn ->
      Plug.Conn.resp(conn, 200, "pong")
    end)

    opts = [interval: 1, sites: ["http://localhost:1234", "http://localhost:1337"]]

    output =
      capture_log(fn ->
        {:ok, _pid} = GenServer.start_link(Scheduler, opts)
        :timer.sleep(10)
      end)

    assert output =~ "[info]  pong"
    assert output =~ "[error] HTTP Status 500"
  end
end

# Não deve haver nada de tão surpreendente no teste acima. Ao invés de criar uma simples conexão Bypass
# no setup, estamos criando duas no teste e especificando suas portas como 1234 e 1337.
# Em seguida, vemos nossas chamadas Bypass.expect/2 e finalmente o mesmo código que temos
# no SchedulerTest para iniciar o scheduler e afirmar que logamos as mensagens apropriadas.

# É isso aí! Construímos um utilitário para nos manter informados se houver qualquer problema
# em nossos domínios e aprendemos como usar o Bypass para escrever melhores testes com serviços externos.
