compreensões são um ‘syntactic sugar’ (uma forma mais simples de escrever)
para realizar loops em Enumerables em Elixir. veremos como podemos
fazer iterações e gerar os resultados utilizando compreensões.

Em alguns casos compreensões podem ser usadas para produzir código mais conciso
para fazer iterações com Enum e Stream. Vamos começar olhando para uma comprehension simples e
então observar suas várias partes:

iex> list = [1, 2, 3, 4, 5]
iex> for x <- list, do: x + 2
# [3, 4, 5, 6, 7]

# A primeira coisa que observamos é o uso de for e um generator (gerador).
# Generators são as expressões x <- [1, 2, 3, 4] encontradas em comprehensions.
# Eles são responsáveis por gerar o próximo valor.

# compreensões não são limitadas a listas; na verdade elas funcionam com qualquer enumerable:
# Keyword Lists
iex> for {_key, val} <- [one: 1, two: 2, three: 3], do: val
# [1, 2, 3]
# Maps
iex> for {key, val} <- %{"a" => "A", "b" => "B"}, do: {key, val}
# [{"a", "A"}, {"b", "B"}]
# Binaries
iex> for <<char <- "hello">>, do: <<char>>
# ["h", "e", "l", "l", "o"]

# generators se apoiam no pattern matching para comparar a entrada definida na variável à esquerda.
# Caso um match não seja encontrado, o valor é ignorado.
iex> for {:ok, val} <- [ok: "Hello", error: "Unknown", ok: "World"], do: val
# ["Hello", "World"]

# Uma compreensão aceita muitos geradores e filtros. Inúmeros geradores são definidos usando <-:
iex> for x <- [1, 2], y <- [2, 3], do: x * y
# [2, 3, 4, 6]

# first..last (macro)
# Operador de criação de alcance(Range creation operator). Retorna um intervalo com os números inteiros especificados
# first e last.
# Se o último(last) for maior que o primeiro(first), o intervalo aumentará do primeiro(first) ao último(last).
# Se o primeiro(first) for maior que o último(last), o intervalo será decrescente do primeiro(first) ao último(last).
# Se o primeiro(first) for igual ao último(last), o intervalo conterá um elemento, que é o próprio número.

iex> for n <- [1, 2, 3, 4], times <- 1..n do
# iex> for n <- [1, 2, 3, 4], times <- [1,2,3,4] do
  IO.puts "n: #{n} - times: #{times}"
end
# n: 1 - times: 1
# n: 2 - times: 1
# n: 2 - times: 2
# n: 3 - times: 1
# n: 3 - times: 2
# n: 3 - times: 3
# n: 4 - times: 1
# n: 4 - times: 2
# n: 4 - times: 3
# n: 4 - times: 4
# [:ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok]


# Você pode pensar em filtros como um tipo de guard para compreensões.
# Quando um valor filtrado retorna false ou nil ele é excluído da lista final.
import Integer
iex> for x <- 1..10, is_even(x), do: x
# [2, 4, 6, 8, 10]
iex> for x <- 1..10, is_odd(x), do: x
# [1, 3, 5, 7, 9]

# também podemos usar múltiplos filtros.
iex> for x <- 1..10, is_even(x), rem(x, 3) == 0 , do: x
# [6]

# Os geradores também podem ser usados ​​para filtrar, pois remove qualquer valor que não corresponda
# ao padrão no lado esquerdo de <- :
iex> users = [user: "john", admin: "meg", guest: "barbara"]
iex> for {type, name} when type != :guest <- users do
  String.upcase(name)
end
# ["JOHN", "MEG"]

# left :: right
# Operador de tipo. Usado por tipos e bitstrings para especificar tipos.
# Este operador é usado em duas ocasiões distintas no Elixir. É usado em typespecs para especificar
# o tipo de uma variável, função ou do próprio tipo:
# Também pode ser usado em cadeias de bits para especificar o tipo de um determinado segmento de bits:

iex> pixels = <<213, 45, 132, 64, 76, 32, 76, 0, 0, 234, 32, 15>>
iex> for <<r::8, g::8, b::8 <- pixels>>, do: {r, g, b}
# [{213, 45, 132}, {64, 76, 32}, {76, 0, 0}, {234, 32, 15}]

# se quisermos produzir algo que não seja uma lista? Passando a opção :into nós podemos fazer exatamente isso!
# Como uma regra geral, :into aceita qualquer estrutura que implemente o protocolo Collectable.
iex> for {key, val} <- [one: 1, two: 2, three: 3], into: %{}, do: {key, val}
# %{one: 1, three: 3, two: 2}
iex> for c <- [72, 101, 108, 108, 111], into: "", do: <<c>>
# "Hello"

# O módulo IO fornece streams, que são Enumerable e Collectable, aqui está um servidor de eco em maiúsculas usando compreensões:
for line <- IO.stream(:stdio, :line), into: IO.stream(:stdio, :line) do
  String.upcase(line)
end

# uniq: true, também pode ser fornecido para compreensões para garantir que os resultados
# só sejam adicionados à coleção se não forem retornados antes.
iex> for x <- [1, 1, 2, 3], uniq: true, do: x * 2
# [2, 4, 6]
iex> for <<x <- "abcabc">>, uniq: true, into: "", do: <<x - 32>>
# "ABC"

# Quando a chave :reduce é colocada, seu valor é usado como o acumulador inicial e o bloco de do
# deve ser alterado para uso -> cláusulas, onde o lado esquerdo -> recebe o valor acumulado da iteração anterior
# e a expressão do lado direito deve retornar o novo valor do acumulador. Quando não houver mais elementos,
# o valor final acumulado é retornado. Se não houver nenhum elemento, o valor inicial do acumulador será retornado.
for <<x <- "AbCabCABc">>, x in ?a..?z, reduce: %{} do
  acc -> Map.update(acc, <<x>>, 1, & &1+1)
end
# %{"a" => 1, "b" => 2, "c" => 1}

# &(expr)
# Operador Capture. Captura ou cria uma função anônima.
