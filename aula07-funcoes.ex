# Para definir uma função anônima em Elixir nós precisamos das palavras-chave fn e end.
# Dentro destes, podemos definir qualquer número de parâmetros () e corpos separados por ->.

iex> sum = fn (a, b) -> a + b end
iex> sum.(1,3)
# 4

# taquigrafia  &  Utilizar funções anônimas é uma prática comum em Elixir, há uma taquigrafia para fazê-lo:
iex> sum = &(&1 + &2)
iex> sum.(2, 3)
# 5

# Elixir utiliza pattern matching para verificar todas as possíveis opções de match e identificar
# o primeiro conjunto de parâmetros associados para executar seu respectivo corpo.
iex> handleResult = fn
...>   {:ok, result} -> IO.puts "Lidando com resultados... resultado = #{result}"
...>   {:ok, _} -> IO.puts "Isso nunca sera executado, pois o anterior sera correspondido corretamente."
...>   {:error} -> IO.puts "Ocorreu um erro!"
...> end

iex> someResult = 1
iex> handleResult.({:ok, someResult})
# Lidando com resultados... resultado = 1
iex> handleResult.({:error})
# Ocorreu um erro!

# Funções nomeadas, estas funções nomeadas são definidas com a palavra-chave def dentro de um módulo.
# def (nome, expresao \\ nil)(macro)
  # Define uma função pública com o nome e corpo fornecidos.
# defmodule (alias, do_block)(macro)
  # Define um módulo dado por nome com o conteúdo fornecido.
defmodule Alias do
  def nome(), do: "corpo"
end

defmodule Alias do
  def nome() do
    "corpo"
  end
end
#############################
iex> defmodule Soma do
...>   def soma(x), do: x + 1
...> end
iex> Soma.soma(5)
# 6
iex> defmodule Soma do
...>   def soma(x) do
...>     x + 1
...>   end
...> end
iex> Soma.soma(5)
# 6

# Nomear Funções e a Aridade
# funções são nomeadas pela combinação do nome e aridade (quantidade dos argumentos) das funções.
iex> defmodule Somar do
...>   def soma(), do: "nao tem nada para somar"     # soma/0
...>   def soma(x), do: "#{x}+10 = " <> "#{x + 10}"  # soma/1
...>   def soma(x, y) do
...>      "nao somamos aqui, os numeros #{x} e #{y}" # soma/2
...>   end
...> end
iex> Somar.soma()
# "nao tem nada para somar"
iex> Somar.soma(5)
# "5+10 = 15"
iex> Somar.soma(5,5)
# "nao somamos aqui, os numeros 5 e 5"

#
iex> defmodule Person do
...>   def hello(%{name: personName}) do
...>     IO.puts "Hello, " <> personName
...>   end
...> end
iex> dev = %{
...> name: "Desenvolverdor",
...> age: 2021,
...> lang: "pt-BR"
...> }
iex> Person.hello(dev)
# "Hello, Desenvolverdor"

iex> Person.hello(%{age: 2021})
# ** (FunctionClauseError) no function clause matching in Person.hello/1
#     The following arguments were given to Person.hello/1:
#         # 1
#         %{age: 2021}
#     iex: Person.hello/1

iex> dev = %{name: "Desenvolverdor", age: 2021, lang: "pt-BR"}
iex> person = %{name: "Desenvolverdor", age: 2021, lang: "pt-BR"}
iex> defmodule Person1 do
...>   def hello(person = %{name: personName}) do
...>     IO.puts "Hello, " <> personName
...>     IO.inspect person
...>   end
...> end
iex> Person.hello(dev)
# Hello, Desenvolverdor
iex> Person.hello(person)
# Hello, Desenvolverdor

# Funções privadas, Quando não quisermos que outros módulos acessem uma função específica,
# nós podemos torná-la uma função privada, que só podem ser chamadas dentro de seus módulos.
# Nós podemos defini-las em Elixir com defp:
# defp (chamar, expr \\ nil)(macro)
# Define uma função privada com o nome e corpo fornecidos.
defmodule Saudacao do
  def pessoa(name), do: saudacao <> name
  defp saudacao, do: "Ola, "
end

iex> Saudacao.pessoa("HR")
# "Ola, HR"
iex> Saudacao.saudacao()
# ** (UndefinedFunctionError) function Saudacao.saudacao/0 is undefined or private Saudacao.saudacao()

defmodule Greeter do
  def hello(names) when is_list(names) do
    names
      |> Enum.join(", ")
      |> hello
    # "Sean, Steve"
  end

  def hello(name) when is_binary(name) do
    phrase() <> name
  end

  defp phrase, do: "Hello, "
end

iex> Greeter.hello(["Sean", "Steve"])
# iex> Greeter.hello ["Sean", "Steve"]
# "Hello, Sean, Steve"


# Argumentos padrão é usado \\ para especificar um valor padrão para um parâmetro de uma função.
# nós usamos a sintaxe argumento \\ valor:
iex> defmodule Args do
...>   def multiply_by(number, factor \\ 2) do
...>     number * factor
...>   end
...>   def hello(name, language_code \\ "en") do
...>     phrase(language_code) <> name
...>   end
...>   defp phrase("en"), do: "Hello, "
...>   defp phrase("pt"), do: "Olá, "
...> end

iex> Args.multiply_by(4, 3)
# 12
iex> Args.multiply_by(4)
# 8
iex> Args.hello("Sean", "en")
# "Hello, Sean"
iex> Args.hello("Sean")
# "Hello, Sean"
iex> Args.hello("Sean", "pt")
# "Olá, Sean"
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
iex> defmodule Greeter do
...>   def hello(names, language_code \\ "en")
...>
...>   def hello(names, language_code) when is_list(names) do
...>     names
...>     |> Enum.join(", ")
...>     |> hello(language_code)
...>   end
...>
...>   def hello(name, language_code) when is_binary(name) do
...>     phrase(language_code) <> name
...>   end
...>
...>   defp phrase("en"), do: "Hello, "
...>   defp phrase("pt"), do: "Ola, "
...> end

iex> Greeter.hello ["Sean", "Steve"]
# "Hello, Sean, Steve"

iex> Greeter.hello(["Sean", "Steve"], "pt")
# iex> Greeter.hello ["Sean", "Steve"], "pt"
# "Olá, Sean, Steve"
