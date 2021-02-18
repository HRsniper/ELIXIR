# Um dos benefícios adicionais em se construir em cima da Erlang VM (BEAM) é a abundância de bibliotecas existentes
# disponíveis para nós. A interoperabilidade nos permite usar essas bibliotecas e a biblioteca padrão Erlang
# a partir do nosso código Elixir.


# A extensa biblioteca padrão Erlang pode ser acessada de qualquer código Elixir em nossa aplicação.
# Módulos Erlang são representados por átomos em caixa baixa como :os e :timer.

# vamos abrir o nosso projeto e em lib/erlang.ex

defmodule ErlangExample do
  def timed(fun, args) do
    {time, result} = :timer.tc(fun, args)
    IO.puts("Time: #{time} microseconds")
    IO.puts("Result: #{result}")
  end
end

cli> iex -S mix

iex> ErlangExample.timed(fn (n) -> (n * n) * n end, [100])
# Time: 0 microseconds
# Result: 1000000
# :ok

# documentação dos módulos do erlang : http://erlang.org/doc/apps/stdlib/

# Incluir bibliotecas Erlang funciona da mesma maneira que as do elixir.
# Caso a biblioteca Erlang não tenha sido publicada no Hex, você pode alternativamente utilizar seu repositório git

# mix.exs do projeto:
{:png, github: "yuce/png"} ou {:png, "~> 0.2.1"}


# Diferenças notáveis
# Agora que sabemos como usar Erlang, junto com a interoperabilidade existe alguns contrapontos.

# Átomos Erlang são similares aos de Elixir, só que sem os dois pontos (:).
# Eles são representados por strings e underscores em caixa baixa:
Elixir      Erlang
:example    example.

# Strings Em Elixir são binários codificados em UTF-8.
# Em Erlang, strings continuam usando aspas mas representam listas de caracteres:

Elixir:
iex> is_list('Example')
# true
iex> is_list("Example")
# false
iex> is_binary("Example")
# true
iex> <<"Example">> === "Example"
# true

Erlang:
1> is_list('Example').
# false
2> is_list("Example").
# true
3> is_binary("Example").
# false
4> is_binary(<<"Example">>).
# true

# Variáveis
# Em Erlang, variáveis começam com caixa alta e a reassociação de variáveis não é permitida.
Elixir:
iex> x = 10
# 10
iex> x = 20
# 20
iex> x1 = x + 10
# 30

Erlang:
1> X = 10.
# 10
2> X = 20.
# ** exception error: no match of right hand side value 20
2> X1 = X + 10.
# 20

Utilizar Erlang a partir da nossa aplicação Elixir é fácil
e efetivamente dobra o número de bibliotecas disponíveis para nós.
