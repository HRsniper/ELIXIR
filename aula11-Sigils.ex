# Elixir fornece uma sintaxe alternativa para representar e trabalhar com literais.
# Um sigil (símbolo especial) vai começar com um til ~ seguido por um caractere.
# O núcleo do Elixir fornece-nos alguns sigils, no entanto, é possível criar o nosso próprio
# precisamos estender a linguagem.

# Uma lista de sigils disponíveis incluem:
#   ~C Gera uma lista de caracteres sem escape ou interpolação
#   ~c Gera uma lista de caracteres com escape e interpolação
#   ~R Gera uma expressão regular sem escape ou interpolação
#   ~r Gera uma expressão regular com escape e interpolação
#   ~S Gera strings sem escape ou interpolação
#   ~s Gera string com escape e interpolação
#   ~W Gera uma lista sem escape ou interpolação
#   ~w Gera uma lista com escape e interpolação
#   ~N Gera uma NaiveDateTime struct

# Uma lista de delimitadores inclui:
#   <...> Um par de brackets
#   {...} Um par de chaves
#   [...] Um par de colchetes
#   (...) Um par de parênteses
#   |...| Um par de pipes
#   /.../ Um par de barras
#   "..." Um par de aspas duplas
#   '...' Um par de aspas simples

# Lista de Caracteres = ~c e ~C sigils geram listas de caracteres respectivamente.
iex> ~c/2 + 7 = #{2 + 7}/
# '2 + 7 = 9'
iex> ~C/2 + 7 = #{2 + 7}/
# '2 + 7 = \#{2 + 7}'

Expressões Regulares = ~r e ~R sigils são usados para representar Expressões Regulares.
iex> regex = ~r/elixir/
# ~r/elixir/
iex> "Elixir" =~ regex
# false
iex> "elixir" =~ regex
# true

iex> regex_insensitive = ~r/elixir/i
iex> "Elixir" =~ regex
# true
iex> "elixir" =~ regex
# true

# Elixir fornece a API Regex (https://hexdocs.pm/elixir/Regex.html), que é construída em cima da biblioteca
# de expressão regular do Erlang. Vamos implementar Regex.split/2 usando um sigil regex.
iex> string = "100_000_000"
# "100_000_000"
iex> Regex.split(~r/_/, string)
# ["100", "000", "000"]

# https://regex101.com/ é bom site para testa regex

# String = ~s e ~S sigils são usados para gerar dados de String.
iex> ~s/Elixir Functional Programing #{"Lang" <> "uage"}/
"Elixir Functional Programing Language"

iex> ~S/Elixir Functional Programing #{Language}/
"Elixir Functional Programing \#{\"Lang\" <> \"uage\"}"

# Lista de Palavras do tipo sigil pode ser muito útil. Pode lhe economizar tempo, digitação e possivelmente,
# reduzir a complexidade dentro da base de código.
iex> ~w/i love #{'e'}lixir school/
# ["i", "love", "elixir", "school"]

iex> ~W/i love #{'e'}lixir school/
# ["i", "love", "\#{'e'}lixir", "school"]

# Uma NaiveDateTime (https://hexdocs.pm/elixir/NaiveDateTime.html) pode ser bem útil para criar rapidamente
# uma struct que representa um DateTime sem um timezone.
iex> ~N[2021-02-09 15:27:45]
# ~N[2021-02-09 15:27:45]
iex> date = ~N[2021-02-09 15:27:45]
# Os campos de data e hora na estrutura podem ser acessados ​​diretamente
iex> date.year
# 2021
iex> date.month
# 2
iex> date.day
# 9
iex> date.hour
# 15
iex> date.minute
# 27
iex> date.second
# 45

iex> NaiveDateTime.from_iso8601("2015-01-23 23:50:07") == {:ok, ~N[2015-01-23 23:50:07]}
# true
iex> NaiveDateTime.to_iso8601(~N[2015-01-23 23:50:07]) == "2015-01-23T23:50:07"
# true



# Criando Sigils Um dos objetivos do Elixir é ser uma linguagem de programação extensível.
# Não é surpresa então que você possa facilmente criar o seu próprio sigil customizado.
# vamos criar um sigil para converter uma cadeia para letras maiúsculas.
# Como já existe uma função para isso no núcleo do Elixir (String.upcase/1),
# vamos embrulhar o nosso sigil em torno desta função.
defmodule StringSigils do
  def sigil_u(string, []), do: String.upcase(string)
end

iex> import StringSigils
# StringSigils

iex> ~u/elixirschool.com/
# "ELIXIRSCHOOL.COM"

# Primeiro definimos um módulo chamado StringSigils e dentro deste módulo, criamos uma função chamada sigil_u.
# Como não existe nenhum sigil ~u no espaço de sigil existente, vamos usá-lo. O _u indica que desejamos usar
# u como caractere depois do til. A definição da função deve receber dois argumentos, uma entrada e uma lista.
