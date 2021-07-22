# Mox é uma biblioteca feita para criar mocks concorrentes em Elixir.


# Os testes e as simulações (mocks) que os facilitam geralmente não são os destaques
# chamativos de nenhuma linguagem, então talvez não seja surpreendente que haja menos escritos sobre eles.
# No entanto, você pode usar absolutamente mocks no Elixir! A metodologia exata pode ser diferente
# daquela com a qual você está familiarizado em outras linguagens, mas o objetivo final é o mesmo:
# os mocks podem simular a saída de funções internas e, assim, permitir que você assuma todos os caminhos
# de execução possíveis em seu código.

# Antes de entrarmos em casos de uso mais complexos, vamos falar sobre algumas técnicas que podem nos ajudar
# a tornar nosso código mais testável. Uma tática simples é passar um módulo para uma função,
# em vez de codificar o módulo dentro da função.

# Por exemplo, se tivéssemos codificado um cliente HTTP dentro de uma função:
def get_username(username) do
  HTTPoison.get("https://elixirschool.com/users/#{username}")
end

# Poderíamos, em vez disso, passar o módulo do cliente HTTP como argumento assim:
def get_username(username, http_client) do
  http_client.get("https://elixirschool.com/users/#{username}")
end

# Ou poderíamos usar a função apply/3 que realiza o mesmo:
def get_username(username, http_client) do
  apply(http_client, :get, ["https://elixirschool.com/users/#{username}"])
end

# Passar o módulo como argumento ajuda a separar as responsabilidades e, se não nos assustarmos demais
# com a verbosidade de programação orientada a objetos na definição, poderemos reconhecer esta inversão
# de controle como uma espécie de Injeção de Dependência.

# Para testar o método 'get_username/2', você só precisaria passar um módulo com uma função 'get'
# que retorne o valor necessário para as suas verificações.
# Esta lógica é muito simples, e, por isso, é apenas útil quando a função é facilmente acessível
# e não quando está enterrada em algum lugar bem fundo de uma função privada.

# Uma tática mais flexível depende da configuração do aplicativo. Talvez você nem tenha percebido,
# mas um aplicativo Elixir mantém o estado em sua configuração. Em vez de chamar um módulo diretamente
# ou passá-lo como um argumento, você pode lê-lo na configuração do aplicativo.

def get_username(username) do
  http_client().get("https://elixirschool.com/users/#{username}")
end

defp http_client do
  Application.get_env(:my_app, :http_client)
end

# Então, no seu arquivo de configuração (config.exs, dev.exs, test.exs ou prod.exs)
config :my_app, :http_client, HTTPoison

# Essa lógica de construção e a sua dependência na configuração da aplicação forma a base de tudo que se segue.

# Se você está propenso a pensar demais, sim, você pode omitir a função 'http_client/0'
# e chamar 'Application.get_env/2' diretamente e, sim, você também pode fornecer um terceiro argumento padrão
# para 'Application.get_env/3' e obter o mesmo resultado.

# Aproveitar a configuração do aplicativo nos permite ter implementações específicas do módulo
# para cada ambiente; você pode fazer referência a um módulo sandbox para o ambiente de desenvolvimento,
# enquanto o ambiente de teste pode usar um módulo na memória.

# No entanto, ter apenas um módulo fixo por ambiente pode não ser flexível o suficiente:
# dependendo de como sua função é usada, você pode precisar retornar respostas diferentes para testar todos
# os caminhos de execução possíveis. O que a maioria das pessoas não sabe é que você pode alterar
# a configuração do aplicativo em tempo de execução!

# Vamos dar uma olhada em 'Application.put_env/4'.

# Imagine que seu aplicativo precisasse agir de maneira diferente dependendo se a solicitação HTTP
# foi bem-sucedida ou não. Poderíamos criar vários módulos, cada um com uma função 'get/1'.
# Um módulo pode retornar uma tupla {:ok, message: "OK"}, o outro pode retornar uma tupla {:error, reason}.
# Então, poderíamos usar 'Application.put_env/4' para definir a configuração antes de chamar
# nossa função 'get_username/1'.

# Não faça isso! é somente para explicação
defmodule MyAppTest do
  use ExUnit.Case

  setup do
    http_client = Application.get_env(:my_app, :http_client)

    on_exit(
      fn ->
        Application.put_env(:my_app, :http_client, http_client)
      end
    )
  end

  test ":ok on 200" do
    Application.put_env(:my_app, :http_client, HTTP200Mock)
    assert {:ok, _} = MyModule.get_username("twinkie")
  end

  test ":error on 404" do
    Application.put_env(:my_app, :http_client, HTTP404Mock)
    assert {:error, _} = MyModule.get_username("does-not-exist")
  end
end

# Imaginando que temos criado os módulos necessários em algum lugar (HTTP200Mock e HTTP404Mock).
# Nós adicionamos um callback 'on_exit' ao setup para assegurar que o ':http_client'
# é devolvido ao seu estado anterior depois de cada teste.

# No entanto, um padrão como o de acima geralmente NÃO é algo que você deve seguir!
# As razões para isso podem não ser imediatamente óbvias.
# -> Em primeiro lugar, não há nada que garanta que os módulos que definimos para o nosso ':http_client'
# possam fazer o que precisam:
# - não há um contrato definido aqui que exija que os módulos tenham uma função 'get/1'.
# -> Em segundo lugar, testes como o acima não podem ser executados de forma assíncrona com segurança.
# Como o estado do aplicativo é compartilhado por todo o aplicativo, é completamente possível que,
# ao substituir ':http_client' em um teste, algum outro teste (em execução simultaneamente)
# espere um resultado diferente. Você pode ter encontrado problemas como este quando as execuções
# de teste geralmente passam, mas às vezes falham inexplicavelmente. Cuidado!
# -> Em terceiro lugar, essa abordagem pode ficar complicada porque você pode acabar com um monte de módulos
# fictícios enfiados em seu aplicativo em algum lugar 🤢.

# Demonstramos a estrutura acima porque ela descreve a abordagem de uma maneira bastante direta
# que nos ajuda a entender um pouco mais sobre como a solução real funciona.


# utilizando mox, de autoria do próprio José Valim, e resolve todos os problemas delineados acima.
# e vamos usar httpoison como http client.

$ mix phx.new  aula47_mox --no-webpack --no-ecto --no-html --no-gettext --no-dashboard

# em mix.exs
def deps do
  [
    ...
    {:httpoison, "~> 1.8"},
    {:mox, "~> 1.0", only: :test}
  ]
end

# em \lib\mox.ex
defmodule Aula48Mox.MyMox do
  def get_lesson_name(name) do
    http_client().get("https://elixirschool.com/pt/lessons/basics/#{name}")
  end

  defp http_client do
    Application.get_env(:aula48_mox, :http_client)
  end
end

# em \test\test_helper.exs
ExUnit.start()
# definição de mocks dinâmicos
Mox.defmock(HTTPoison.BaseMock, for: HTTPoison.Base)
# Substitua as configurações de 'config' (semelhante a adicioná-las a 'config/test.exs').
Application.put_env(:aula48_mox, :http_client, HTTPoison.BaseMock)

# Algumas coisas importantes a serem observadas sobre 'Mox.defmock':
# - o nome do lado esquerdo é arbitrário (que não segue regras ou normas).
#   Os nomes dos módulos no Elixir são apenas átomos.
# - você não precisa criar um módulo em qualquer lugar, tudo o que você está fazendo é "reservando"
#   um nome para o módulo simulado. Nos bastidores, o Mox criará um módulo com este nome em tempo real
#   dentro do BEAM.

# A segunda coisa complicada é que o módulo referenciado por 'for:' deve ser um comportamento (behaviour):
# - ele deve definir retornos de chamada (callbacks). Mox usa introspecção neste módulo
#   e você só pode definir funções simuladas quando um '@callback' foi definido. É assim que Mox faz cumprir um contrato.
#   Às vezes, pode ser difícil encontrar o módulo de comportamento:
#   - HTTPoison, por exemplo, depende do 'HTTPoison.Base', mas você pode não saber disso,
#   a menos que examine seu código-fonte. Se você está tentando criar um mock para um pacote de terceiros,
#   você pode descobrir que não existe nenhum comportamento! Nesses casos, você pode precisar definir
#   seu próprio comportamento e retornos de chamada para satisfazer a necessidade de um contrato.

# Isso traz um ponto importante: você pode querer usar uma camada de abstração (ou seja, operador de desreferência ou operador de indireção)
# para que seu aplicativo não dependa de um pacote de terceiros diretamente, mas em vez disso,
# você usaria seu próprio módulo que, por sua vez, usa o pacote.
# É importante para um aplicativo bem elaborado definir os "limites" adequados,
# mas a mecânica das simulações não muda, então não se deixe enganar.

# Finalmente, em seus módulos de teste, você pode colocar seus mocks em uso importando Mox
# e chamando sua função ':verify_on_exit!'. Então você está livre para definir valores de retorno
# em seus módulos fictícios usando uma ou mais chamadas para a função 'expect':
defmodule MyAppTest do
  use ExUnit.Case, async: true
  # 1. Importar Mox
  import Mox
  # 2. setup da configuração
  setup :verify_on_exit!

  test ":ok on 200" do
    expect(HTTPoison.BaseMock, :get, fn _ -> {:ok, "What a guy!"} end)

    assert {:ok, _} = MyModule.get_username("twinkie")
  end

  test ":error on 404" do
    expect(HTTPoison.BaseMock, :get, fn _ -> {:error, "Sorry!"} end)
    assert {:error, _} = MyModule.get_username("does-not-exist")
  end
end

# em \test\my_mox_test.exs
defmodule Aula48Mox.MyMoxTest do
  use ExUnit.Case, async: true
  alias Aula48Mox.Mox

  import Mox
  setup :verify_on_exit! # Certifica-se de que as simulações sejam verificadas quando o teste terminar.

  test ":ok on 200" do
    expect(HTTPoison.BaseMock, :get, fn _ -> {:ok, "What a guy!"} end)

    assert {:ok, _} = MyMox.get_lesson_name("twinkie")
  end

  test ":error on 404" do
    expect(HTTPoison.BaseMock, :get, fn _ -> {:error, "Sorry!"} end)
    assert {:error, _} = MyMox.get_lesson_name("does-not-exist")
  end
end

$ mix test
....
Finished in 0.2 seconds (0.2s async, 0.00s sync)
4 tests, 0 failures


# Para cada teste, nós fazemos referência ao mesmo módulo mock (HTTPoison.BaseMock neste exemplo),
# e usamos a função 'expect' para definir o valor que é retornado para cada função chamada.
# Usar o Mox é perfeitamente seguro para uma execução assíncrona, e requer que cada mock siga um contrato.
# Atendendo que estes mocks são “virtuais”, não há necessidade de definir módulos reais
# que poderiam atrapalhar a nossa aplicação.
