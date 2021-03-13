# https://hexdocs.pm/elixir/typespecs.html

@spec - é mais uma sintaxe complementar para escrever documentação que pode ser analisada por ferramentas.
@type - nos ajuda a escrever código de fácil leitura e entendimento.

# As especificações de tipo (às vezes chamadas de typespecs )
# são definidas em diferentes contextos usando os seguintes atributos:
  # @type
  # @opaque
  # @typep
  # @spec
  # @callback
  # @macrocallback


# Não é incomum querer descrever a interface de sua função. Claro, você pode utilizar a anotação @doc,
# mas isso é somente informação para outros desenvolvedores. Isso não será checado em tempo de compilação.
# Para isso, Elixir tem uma anotação chamada @spec para descrever especificação de função que vai ser analisada pelo compilador.

# Em alguns casos, a especificação é grande e complicada afim de reduzir a complexidade,
# você deverá introduzir um tipo de definição personalizada. a anotação @type para isso.
# Em contra partida, Elixir é uma linguagem dinâmica isso significa que toda informação a respeito
# do tipo será ignorado pelo compilador, mas pode ser utilizada por outras ferramentas.

# Especificação
# você poderá pensar em especificação como uma interface. A especificação define quais os tipos de parâmetros
# da função e o valor de retorno.

# @spec localizada antes da definição da função e tomando como um params nome da função,
# lista de tipos de parâmetros, e depois :: tipo de valor de retorno.

iex> defmodule Sum do
       @spec sum_product(integer) :: integer
       def sum_product(a) do
        [1, 2, 3]
        |> Enum.map(fn el -> el * a end)
        |> Enum.sum()
       end
     end

iex> Sum.sum_product(2)
# 12

# quando chamamos, o resultado válido vai ser retornado, mas a função Enum.sum retorna number
# não integer como era esperado em @spec. Isso pode ser uma fonte de bugs! Existem ferramentas como
# Dialyzer para análises estáticas de código que nos ajudam a localizar esses tipos de bugs.

# Tipos personalizados
# Escrever @spec é bom, mas algumas vezes nossas funções trabalham com mais estruturas
# de dados complexos do que simplesmente números ou coleções.
# Algumas funções precisam ter um número grande de parâmetros ou retornar dados complexos.
# Uma longa lista de parâmetros é um de muitos problemas em potencial em um código.

# Elixir contém alguns tipos básicos como integer, number, list ou pid.
# Você pode encontrar uma lista completa de tipos disponíveis ->
# https://hexdocs.pm/elixir/typespecs.html#types-and-their-syntax

iex> defmodule Sometimes do
       @spec sum_times(integer, %Examples{first: integer, last: integer}) :: integer
       def sum_times(a, params) do
         for i <- params.first..params.last do
           i
         end
         |> Enum.map(fn el -> el * a end)
         |> Enum.sum()
         |> round
       end
     end

# Inserimos uma estrutura no módulo Examples que contém dois campos, first e last.
# Vamos imaginar que precisamos especificar a estrutura Examples em vários lugares.
# Seria chato escrever especificações longas, complexas e isso seria uma fonte de bugs.
# Uma solução para esse problema é @type.
# Elixir tem três diretivas para tipos:
# @type – tipo é público e a estrutura interna do tipo é pública.
# @typep – tipo é privado e pode ser utilizado somente no módulo onde é definido.
# @opaque – tipo é público, mas estrutura interna é privada.

iex> defmodule Examples do
       defstruct first: nil, last: nil

       @type t(first, last) :: %Examples{first: first, last: last}

       @type t :: %Examples{first: integer, last: integer}
     end

# definimos o tipo t(first, last) que recebe parâmetros e é uma representação
# da estrutura %Examples{first: first, last: last}.
# e o tipo t ele é uma representação da estrutura %Examples{first: integer, last: integer}.

# a diferença que t(first, last) pode receber qualquer tipo
# e o t() recebe somente integer

# que significa um código como este:
@spec sum_times(integer, Examples.t()) :: integer
def sum_times(a, params) do
  for i <- params.first..params.last do
    i
  end
  |> Enum.map(fn el -> el * a end)
  |> Enum.sum()
  |> round
end

# É igual ao código:
@spec sum_times(integer, Examples.t(integer, integer)) :: integer
def sum_times(a, params) do
  for i <- params.first..params.last do
    i
  end
  |> Enum.map(fn el -> el * a end)
  |> Enum.sum()
  |> round
end

# vamos testar
iex> defmodule Examples do
  defstruct first: nil, last: nil

  @type t(first, last) :: %Examples{first: first, last: last}
  @type t :: %Examples{first: integer, last: integer}
end

iex> defmodule Sometimes do
  @spec sum_times(integer, Examples.t(integer, integer)) :: integer
  def sum_times(a, params) do
    for i <- params.first..params.last do
      i
    end
    |> Enum.map(fn el -> el * a end)
    |> Enum.sum()
    |> round
  end
end

iex> Sometimes.sum_times(2, %{first: 1, last: 5})
# 30
iex> Sometimes.sum_times(2, %Examples{first: 1, last: 5})
# 30

# Documentação de tipos
# temos as anotações @doc e @moduledoc para criar documentação para funções e módulos.
# Para documentar nossos tipos, usamos @typedoc:
defmodule Examples do
  @typedoc """
      Tipo que representa a estrutura Examples com :first como integer e :last como integer.
  """
  @type t :: %Examples{first: integer, last: integer}
end

# A diretiva @typedoc é similar a @doc e @moduledoc.
