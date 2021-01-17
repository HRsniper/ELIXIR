# Listas
# As listas são simples coleções de valores que podem incluir múltiplos tipos; listas também podem incluir valores não-exclusivos:
iex> [3.14, :array, "game"]

# Elixir implementa listas como listas encadeadas. Isso significa que acessar o tamanho da lista é uma operação que rodará em tempo linear (O(n)). Por essa razão, é normalmente mais rápido inserir um elemento no início (prepending) do que no final (appending):

iex> list = [3.14, :array, "game"]
# Prepending (rápido)
iex> ["programacao" | list]
["programacao", 3.14, :array, "game"]
# Appending (lento)
iex> list ++ ["elixir"]
[3.14, :array, "game", "elixir"]

# Concatenação de listas A concatenação de listas usa o operador ++/2.
iex> [1, 2] ++ [3, 4, 1]
# [1, 2, 3, 4, 1]

# o formato de nome (++/2), o nome de uma função ou operador tem dois componentes: o nome em si (neste caso ++)
# e sua aridade(neste caso /2).Aridade indica o número de argumentos que uma dada função aceita (dois, nesse exemplo).

# Subtração de listas O suporte para subtração é provido pelo operador --/2; é seguro subtrair um valor que não existe:
iex> ["elixir", :typescript, 42] -- [42, "typescript"] # "typescript" nao existe na lista da esquerda
# ["elixir", :typescript]
# Esteja atento para valores duplicados. Para cada elemento na direita,
# a primeira ocorrência deste é removida da esquerda:
iex> [1,2,2,3,2,3] -- [1,2,3,2]
# [#,#,2,#,#,3]
# [2, 3] final

# subtração de listas usa comparação estrita para match de valores.
iex> [2] -- [2.0]
# [2]
iex> [2.0] -- [2.0]
# []

# Head / Tail
# Quando usamos listas é comum trabalhar com o topo(head) e o fim da lista(tail).
# O topo(head) é o primeiro elemento da lista e a cauda(tail) são os elementos restantes.
# Elixir provê duas funções bem úteis, hd e tl.
  # hd = head, retorna o primeiro elemento da lista
  # tl = tl, retorna o restante dos elementos da lista
iex> hd [3.14, :array, "game", "elixir","programacao"]
# 3.14
iex> tl [3.14, :array, "game", "elixir","programacao"]
# [:array, "game", "elixir", "programacao"]

# Além das funções citadas, pode-se usar pattern matching e o operador cons (|)
# para dividir a lista em topo e cauda;
iex> [head | tail] = [3.14, :array, "game", "elixir","programacao"]
# [3.14, :array, "game", "elixir","programacao"]
iex> head
# 3.14
iex> tail
# [:array, "game", "elixir","programacao"]

# Tuplas
# As tuplas são similares às listas porém são armazenadas de maneira proxima da memória.
# Isto permite acessar seu tamanho de forma rápida porém sua modificação é custosa;
# a nova tupla deve ser armazenada inteira na memória. As tuplas são definidas com chaves {}.

iex> {:pi, 7.0, "string"}

# É comum usar tuplas como um mecanismo que retorna informação adicional de funções;
iex> File.read("hello.txt")
# {:ok, "World"}
iex> File.read("invalid.txt")
# {:error, :enoent}

# Listas de palavras-chave
# As listas de palavras-chave e os mapas são coleções associativas no Elixir.
# No Elixir, uma lista de palavras-chave é uma lista especial de tuplas de dois elementos
# cujo o primeiro elemento é um átomo; eles compartilham o desempenho das listas.
iex> [ele1: "nome1", ele2: "nome2"]
# um atomo quando em uma lista usa-se : a direita
iex> [ele1: "nome1", :ele2 "nome2"]
# ** (SyntaxError) iex:19:17: syntax error before: ele2

# lista de palavras-chave
iex> [{:ele1, "nome1"}, {:ele3, "nome3"},{:ele2, "nome2"}]
# [ele1: "nome1", ele3: "nome3", ele2: "nome2"]

# As três características relevantes das listas de palavras-chave são:
  # As chaves são átomos.
  # As chaves estão ordenadas.
  # As chaves não são únicas.
# Por essas razões as listas de palavras-chave são frequentemente usadas para passar opções a funções.

# Mapas
# Em Elixir, mapas normalmente são a escolha para armazenamento chave-valor.
# A diferença entre os mapas e as listas de palavras-chave está no fato de que os mapas
# permitem chaves de qualquer tipo e não seguem uma ordem. Você pode definir um mapa com a sintaxe %{}:
# % {:chave => valor}
# % {chave: valor}

iex> %{:foo => "bar", "hello" => :world}
# %{:foo => "bar", "hello" => :world}
iex> map = %{:foo => "bar", "hello" => :world}
# %{:foo => "bar", "hello" => :world}
iex> map[:foo]
# "bar"
iex> map["hello"]
# :world

# há uma sintaxe especial para os mapas que contém apenas átomos como chaves:
iex> map = %{foo: "bar", hello: :world}
# %{foo: "bar", hello: :world}
iex> map[:hello]
# :world
iex> %{foo: "bar", hello: :world} == %{:foo => "bar", :hello => :world}
# true
# existe uma sintaxe especial para acessar átomos como chaves:
iex> map.foo
# "bar"
iex> map.hello
# :world

# variáveis são permitidas como chaves do mapa:
iex> key = "hello"
# "hello"
iex> %{key => "world"}
# %{"hello" => "world"}

# Se um elemento duplicado é inserido no mapa, este sobrescreverá o valor anterior;
iex> %{:foo => "bar", :foo => "hello world"}
# %{foo: "hello world"}

# Outra propriedade interessante de mapas é que eles têm sua própria sintaxe para atualizar
# e acessar átomos como chaves:
iex> map = %{foo: "bar", hello: "world"}
# %{foo: "bar", hello: "world"}
iex> %{map | foo: "foo"}
# %{foo: "foo", hello: "world"}

# esta sintaxe funciona apenas para atualizar uma chave que já existe no mapa! Se a chave não existir, um KeyError será gerado.
iex> %{map | bar: "bar"}
# ** (KeyError) key :bar not found in: %{foo: "bar", hello: "world"}

# Para criar uma nova chave, use Map.put/3: Coloca o valor do dado sobre a chave no mapa.
# put (mapa, chave, valor) retona um novo mapa
iex> map = %{chave: "valor", hello: "world"}
iex> Map.put(map, :bar, "valor do bar")
# %{bar: "valor do bar", chave: "valor", hello: "world"}
