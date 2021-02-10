# Elixir trata de documentação como uma cidadã de primeira classe, oferecendo várias funções de acesso e geração de documentação para seus projetos. O núcleo do Elixir nos fornece muitos atributos diferentes para anotar uma base de código.
  # # - Para documentação em linha.
  # @moduledoc - Para documentação em nível de módulo.
  # @doc - Para documentação em nível de função.

# Documentação em Linha
# Outputs 'Hello, chum.' to the console.
IO.puts("Hello, " <> "chum.")

# Documentação de Módulos
# A anotação @moduledoc permite a documentação em linha em um nível de módulo.
# É tipicamente situada logo abaixo da declaração defmodule no topo de um arquivo.
defmodule Greeter do
  @moduledoc """
  Provides a function `hello/1` to greet a human
  """

  def hello(name) do
    "Hello, " <> name
  end
end

# podemos acessar esta documentação de módulo usando a função h helper dentro de IEx.
# Nós podemos ver por nós mesmos se colocarmos nosso módulo Greeter em um novo arquivo e compilarmos:

iex>  c("aula12-documentacao.ex")
# [Greeter]

iex> h Greeter
# Greeter
# Provides a function hello/1 to greet a human

# Documentação de Funções
# A anotação @doc permite a documentação de funções.
# A anotação @doc fica logo acima da função que está anotando.

defmodule Greeter do
  @moduledoc """
  Provides a function `hello/1` to greet a human
  """

   @doc """
  Prints a hello message
    ## Parameters
      - name: String that represents the name of the person.
    ## Examples
      iex> Greeter.hello("Sean")
      "Hello, Sean"
      iex> Greeter.hello("pete")
      "Hello, pete"
  """
  @spec hello(String.t()) :: String.t()
  def hello(name) do
    "Hello, " <> name
  end
end

# Nota: a anotação @spec é usada para analisar estaticamente o código.

# no projeto example dentro do arquivo chamado lib/example.ex veja se tem @moduledoc e @doc
# e garanta que tudo ainda está funcionando na linha de comando.
# Agora que estamos trabalhando dentro do projeto Mix nós temos que iniciar o IEx usando o comando 'iex -S mix'

iex> h Example.hello
# def hello()
# Hello world.
# ## Examples
#   iex> Example.hello()
#   :world

# Assumindo que tudo está bem, e a saída acima sugere que estamos prontos para configurar ExDoc.
# Dentro do nosso arquivo mix.exs adicione as duas dependências necessárias para começar; :earmark e :ex_doc.
# Nós especificamos o only :dev par de chave-valor, já que não desejamos fazer o download e compilar essas dependências em um ambiente de produção.

# Gerando Documentação
cli> mix deps.get # gets ExDoc + Earmark.

cli> mix docs # fazendo os arquivos da documentação
# Generated example app
# Generating docs...
# View "html" docs at "doc/index.html"
# View "epub" docs at "doc/example.epub"

# dentro do projeto mix agora terá uma pasta doc/ contendo a sua documentação em html
# Agora nós podemos implantar isso para GitHub (http://github.com/), o nosso próprio site, ou mais comumente no HexDocs (https://hexdocs.pm/).

# Boas praticas
# https://github.com/gusaiani/elixir_style_guide/blob/master/README_ptBR.md

# Sempre documente um módulo.
# Caso você não pretenda documentar um módulo, não deixe-o em branco. Considere anotar @moduledoc false

# Quando se refere a funções dentro da documentação de um módulo, use `func/1`

# Use markdown dentro de funções para torná-lo mais fácil de ler, até em caso de leitura através de IEx ou ExDoc.

# Tente incluir alguns exemplos de código em sua documentação
