# if e unless
# if/2 e unless/2 eles trabalham praticamente da mesma forma porém são definidos como macros,
# não construtores da linguagem;implementado no Kernel module (https://hexdocs.pm/elixir/Kernel.html)

# Pode-se notar que em Elixir, os únicos valores falsos são nil e o booleano false.

# if (condição, cláusulas)
# Esta macro espera que o primeiro argumento seja uma condição
# e o segundo argumento uma lista de palavras-chave.

# Exemplos de uma linha
iex> condicao = true
iex> if(condicao, do: "passou")
# "passou"
iex> condicao = false
iex> if(condicao, do: "passou")
# nil
iex> if(condicao, do: "passou", else: "NAO passou")
# "NAO passou"

# Exemplos de blocos
# Observe que do/else/end se tornam delimitadores.
iex> condicao = true
iex> if condicao do
...> "passou"
...> end
# "passou"
iex> condicao = false
iex> if condicao do
...> "passou"
...> end
# nil
iex> if condicao do
...> "passou"
...> else
...> "NAO passou"
...> end
"NAO passou"

# Para comparar mais de duas cláusulas, a cond/1(https://hexdocs.pm/elixir/Kernel.SpecialForms.html#cond/1)
# deve ser usada.

# unless (condição, cláusulas)
# Esta macro avalia e retorna o bloco do (do: / do) passado como o segundo argumento se for (condicional),
# avaliado como um valor falso ( false ou nil). Caso contrário, retorna o valor do bloco else (else: / else)
# se presente ou não.

# Exemplos de uma linha
iex> unless(is_integer("hello"), do: "nao e numero")
# "nao e numero"
iex> unless(is_integer(10), do: "nao e numero")
# nil
iex> unless(is_integer(10), do: "nao e numero", else: "e numero")
# "e numero"

# Exemplos de bloco
iex> unless 2 + 2 === 5 do
...> "4 nao e igual a 5"
...> else
...> "condicao igual a 5"
...> end
# "4 nao e igual a 5"
iex> unless Enum.sum([3, 2]) == 5 do
...> "4 nao e igual a 5"
...> else
...> "condicao igual a 5"
...> end
# "condicao igual a 5"

# casecaso (condição, cláusulas)(macro)
# Corresponde a expressão fornecida às cláusulas.
# implementado no Kernel module (https://hexdocs.pm/elixir/Kernel.SpecialForms.html#case/2)

iex> comparar = {:ok, "Hello World"}
iex> case comparar do
...> {:ok, result} -> result
...> {:error} -> "Uh oh!"
...> _ -> "Catch all"
...> end
# "Hello World"

# case "comparar" do
#   "cabeça" -> "corpo"
#    "..."   -> "..."
#   "cabeça3" -> "corpo3"
# end
# combinamos "comparar" com cada cláusula "cabeça" e executamos a cláusula "corpo"
# retornando à primeira cláusula que corresponde.

# Se nenhuma cláusula corresponder, um erro será gerado. adiciona uma cláusula final
# catch-all (como _) para pegar todos os erros.
iex> x=10
iex> case x do
...>   0 ->
...>     "Esta cláusula não bate"
...>   _ ->
...>     "Esta cláusula bate com qualquer valor (x = #{x})"
...> end
# "Esta cláusula bate com qualquer valor (x = 10)"

# Manipulação de variável
# Observe que as variáveis ​​vinculadas a uma cláusula não vazam para o contexto externo:
iex> case {:ok,"19-01-2021"} do
iex>   {:ok, value} -> value
iex>   :error -> nil
iex> end
# "19-01-2021"
iex> value
# ** (CompileError) iex: undefined function value/0

# Ao associar variáveis ​​com os mesmos nomes das variáveis ​​no contexto externo,
# as variáveis ​​no contexto externo não são afetadas.
iex> value = 7
iex> case false do
...> false -> value = 13
...> end
iex> value
# 7

# Se você pretende procurar padrões em variáveis que já existem, você precisa usar o operador pin ^/1
iex> x = 1
iex> case 1 do
...> ^x -> "valor bate"
...> _ -> "valores diferente de x"
...> end
# "valor bate"
iex> case 10 do
...> ^x -> "valor bate"
...> _ -> "valores diferente de x"
...> end
# "valores diferente de x"

# As cláusulas também permitem que condições extras sejam especificadas por meio de proteções:
# Os guardas começam com o operador(when), seguido por uma expressão de guarda.
# A cláusula será executada somente se a expressão de guarda retornar true.
# Várias condições booleanas podem ser combinadas com os operadores and e or.
iex> case {1, 2, 3} do
...> {1, x, 3} when x > 0 ->
...> "x maior que 0"
...> _ ->
...> "condicao nao satisfeita"
...> end
# "x maior que 0"
iex> case {1, 2, 3} do
...> {1, x, 3} when x == 0 ->
...> "x maior que 0"
...> _ ->
...> "condicao nao satisfeita"
...> end
# "condicao nao satisfeita"


# cond
# cond(clauses)
# Quando necessitamos associar condições, e não valores, nós podemos recorrer ao cond/1;
# Isso é semelhante ao else if ou elsif de outras linguagens:
iex> cond do
...> 2 + 2 == 5 ->
...> "nao e verdadeiro"
...> 2 * 2 == 3 ->
...> "tambem nao e verdadeiro"
...> 1 + 1 == 2 ->
...> "verdareiro"
...> end
# "verdareiro"


# para pegar um error gerado no cond , usa-se a condição (true) para lida com isso
iex> cond do
...> 7 + 1 == 0 -> "incorreto"
...> true -> "erros capturados"
...> end
"erros capturados"

# with
# with(args)(macro)
# Usado para combinar cláusulas de correspondência.A expressão with/1 é composta
# de palavras-chaves, generators e finalmente uma expressão.
# list comprehensions para comparar o lado direito do operador <- com o lado esquerdo.
iex> user = %{first: "Nome", last: "Sobrenome"}
# %{first: "Nome", last: "Sobrenome"}
iex> with {:ok, first} <- Map.fetch(user, :first), {:ok, last} <- Map.fetch(user, :last), do: last <> ", " <> first
# "Sobrenome, Nome"
iex> with ({:ok, first} <- Map.fetch(user, :first),
...> {:ok, last} <- Map.fetch(user, :last)) do
...> last <> ", " <> first
...> end
# "Sobrenome, Nome"

# Quando uma expressão falha em achar um padrão, o valor da expressão que falhou será retornado:
# :error
iex> user = %{first: "Nome"}
iex> with {:ok, first} <- Map.fetch(user, :first),
...>   {:ok, last} <- Map.fetch(user, :last) do
...>     last <> ", " <> first
...>   else
...>     :error -> "nao achou last somente first"
...> end
# "nao achou last somente first"
