# Metaprogramação é o processo de utilização de código para escrever código.
# Em Elixir isso nos dá a capacidade de estender a linguagem para se adequar às nossas necessidades
# e dinamicamente alterar o código

# Metaprogramação é complicado e só deve ser usado quando for absolutamente necessário.
# O uso excessivo certamente levará a um código complexo que é difícil de entender e debugar.

# Quote
# quote(opts, block)
# O primeiro passo para metaprogramação é a compreensão de como as expressões são representadas.
# Em Elixir, a árvore de sintaxe abstrata (AST), a representação interna do nosso código, é composta de tuplas.
# Estas tuplas contêm três partes: o nome da função, metadados e argumentos da função.
# A fim de ver essas estruturas internas, Elixir nos fornece a função quote/2.
# Usando quote/2 podemos converter o código Elixir em sua representação subjacente.

iex> quote do: 42
# 42
iex> quote do "Hello" end
# "Hello"
iex> quote do: :world
# :world
iex> quote do: 1 + 2
# {:+, [context: Elixir, import: Kernel], [1, 2]}
iex> quote do: if(value, do: "True", else: "False")
# {:if, [context: Elixir, import: Kernel],
#  [{:value, [], Elixir}, [do: "True", else: "False"]]}
iex> quote do
  if value do
    :true
  else
    :false
  end
end
# {:if, [context: Elixir, import: Kernel],
# [{:value, [], Elixir}, [do: true, else: false]]}

# Existem 6 literais que retornam eles mesmos quando citados (quoted)
iex> quote do: :atom
# :atom
iex> quote do: "string"
# "string"
iex> quote do: 1 # Todos números
# 1
iex> quote do: 2.0 # Floats
# 2.0
iex> quote do: [1, 2] # Listas
# [1, 2]
iex> quote do: {"hello", :world} # Tuplas de 2 elementos
# {"hello", :world}


# Unquote
# unquote(expr)
# Esta função espera um Elixir AST válido, também conhecido como expressão entre aspas, como argumento.
# Agora que podemos recuperar a estrutura interna do nosso código, como podemos modificá-lo?
# Para injetar novo código ou valores usamos unquote/1. Quando unquote em uma expressão que vai
# ser avaliada e injetado no AST.

iex> denominator = 2
# 2
iex> quote do: divide(42, denominator)
# {:divide, [], [42, {:denominator, [], Elixir}]}
iex> quote do: divide(42, unquote(denominator))
# {:divide, [], [42, 2]}

# Macros
# Uma vez que entendemos quote/2 e unquote/1 estamos prontos para mergulhar em macros.
# É importante lembrar que macros, como todas as metaprogramações, devem ser usadas com moderação.

# No mais simples dos termos, macros são funções especiais destinadas a retornar uma expressão
# entre aspas que será inserido no nosso código do aplicativo.
# Imagine um macro substituído por uma expressão quote, em vez de chamada como uma função.
# Com macros temos tudo que é necessário para estender Elixir e dinamicamente adicionar código para nossas aplicações.

# Começamos por definir um macro usando defmacro/2 que em si é um macro,
# como grande parte da linguagem Elixir (deixar isso imerso).
# defmacro(call, expr \\ nil)
# Define uma macro público com o nome e corpo fornecidos.

iex> defmodule MyMacro do
      defmacro unless(expr, do: block) do
        quote do
          if !unquote(expr), do: unquote(block)
        end
      end
    end

iex> require MyMacro
# MyMacro
iex> MyMacro.unless true, do: "Hi"
# nil
iex> MyMacro.unless false, do: "Hi"
# "Hi"

# Debugando
# sabemos como usar quote/2, unquote/1 e escrever macros.
# Mas e se você tiver uma grande quantidade de código quoted e você precisa entendê-lo?
# Nesse caso, você pode usar Macro.to_string/2.
# https://hexdocs.pm/elixir/Macro.html
# to_string(tree, func \\ fn _ast, string -> string end)
# Converte a expressão AST fornecida em uma string.

iex> Macro.to_string(quote(do: foo.bar(1, 2, 3)))
# "foo.bar(1, 2, 3)"
iex> Macro.to_string(quote(do: 1 + 2), fn _ast, string -> string end)
# "1 + 2"
iex> Macro.to_string(quote(do: 1 + 2), fn
  1, _string -> "one"
  2, _string -> "two"
  _ast, string -> string
end)
# "one + two"

# E quando você quiser ver o código gerado por macros você pode combinar eles com Macro.expand/2 e Macro.expand_once/2,
# essas funções expandem os macros para seus códigos quoted.
# expand(ast, env)
  # Recebe um nó AST e o expande até que não possa mais ser expandido.
# expand_once (ast, env)
  # Recebe um nó AST e o expande uma vez.

iex> defmodule MyMacro do
      defmacro unless(expr, do: block) do
        quote do
          if !unquote(expr), do: unquote(block)
        end
      end
    end

iex> defmodule UseMacro do
      require MyMacro

      def quoted() do
        quoted =
          quote do
            MyMacro.unless(true, do: "Hi")
          end
      end
    end

iex> quoted = UseMacro.quoted()
# {{:., [], [{:__aliases__, [alias: false], [:MyMacro]}, :unless]}, [],
# [true, [do: "Hi"]]}

iex> quoted |> Macro.expand_once(__ENV__) |> Macro.to_string |> IO.puts
# if(!true) do
  # "Hi"
# end
# :ok
iex> quoted |> Macro.expand(__ENV__) |> Macro.to_string |> IO.puts
# case(!true) do
  # x when Kernel.in(x, [false, nil]) ->
    # nil
  # _ ->
    # "Hi"
# end
# :ok

# Macros Privados
# Embora não seja tão comum, Elixir suporta macros privadas. Um macro privado é definido com defmacrop e
# só pode ser chamado a partir do módulo no qual ele foi definido. Macros privados devem ser definidas
# antes do código que as invoca.

# Higienização de Macros
# A característica de como macros interagem com o contexto de quem o chamou quando expandido é
# conhecida como a higienização de macro. Por padrão macros no Elixir são higiênicos e não entrarão em conflito
# com nosso contexto

iex> defmodule Example do
  defmacro hygienic do
    quote do: val = -1
  end
end

iex> require Example
# Example
iex> val = 42
# 42
iex> Example.hygienic
# -1
iex> val
# 42

# Mas e se quisermos manipular o valor de val ? Para marcar uma variável como sendo anti-higiênica
# podemos usar var!/2.
var! (var, contexto \\ nil)
# Marca que determinada variável não deve ser higienizada.

iex> defmodule Example do
  defmacro hygienic do
    quote do: val = -1
  end

  defmacro unhygienic do
    quote do: var!(val) = -1
  end
end

iex> require Example
# Example
iex> val = 42
# 42
iex> Example.hygienic
# -1
iex> val
# 42
iex> Example.unhygienic
# -1
iex> val
# -1

# Ao incluir var!/2 em nossa macro que manipular o valor de val sem passá-la em nossa macro.
# O uso de macros não higiênicos deve ser mantido a um mínimo. Ao incluir var!/2 que aumentam o risco de
# um conflito de resolução de variável.


# Binding
# Nós já cobrimos a utilidade do unquote/1 mas há outra maneira de injetar valores em nosso código: binding.
# Com binding de variável somos capazes de incluir múltiplas variáveis em nossa macro e garantir que eles
# são unquote apenas uma vez, evitando reavaliações acidentais. Para usar variáveis de vinculação precisamos
# passar uma lista de palavras-chave para a opção bind_quoted de quote/2.
# :bind_quoted
  # passa um vínculo para a macro. Sempre que uma ligação é fornecida unquote/1 é automaticamente desabilitado.

iex> defmodule Example do
    defmacro double_puts(expr) do
      quote do
        IO.puts(unquote(expr))
        IO.puts(unquote(expr))
      end
    end
  end

iex> Example.double_puts(:os.system_time)
# 1654341507533824
# 1654341507533824
# :ok

iex> defmodule Example do
  defmacro double_puts(expr) do
    quote bind_quoted: [expr: expr] do
      IO.puts(expr)
      IO.puts(expr)
    end
  end
end

iex> Example.double_puts(:os.system_time)
# 1654341657449472
# 1654341657449472
# :ok
