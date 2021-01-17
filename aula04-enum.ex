# Enum
# Um conjunto de algoritmos para fazer enumeração em coleções

# O módulo Enum inclui mais de 70 funções para trabalhar com enumeráveis.
# Todas as coleções, com exceção das tuplas, são enumeráveis.
# https://hexdocs.pm/elixir/Enum.html#functions
# all?/1    all?/2 = Retorna true se todos os elementos for verdadeiro em enumerable. Itera sobre o enumerable e invoca fun cada elemento. Quando uma chamada de fun retorna um valor falso a iteração para imediatamente e false é retornada.
# all?(enumerable)
# all?(enumerable, fun \\ fn x -> x end)
iex> enumerable = [1,2,3,4,5]

iex> Enum.all?(enumerable, fn element -> rem(element,2) == 0 end)
# false
iex> Enum.all?(enumerable, fn element -> rem(element,element) == 0 end)
# true
iex> Enum.all?([1, 2, 3])
# true
iex> Enum.all?([1, false, 3])
# false
iex> Enum.all?([])
# true

# any?/1    any?/2 = Retorna true se pelo menos um elemento for verdadeiro em enumerable. Itera sobre o enumerable e invoca fun cada elemento. Quando uma chamada de fun retorna um valor verdadeiro a iteração para imediatamente e true é retornada.
# any?(enumerable)
# any?(enumerable, fun \\ fn x -> x end)
iex> Enum.any?(enumerable, fn element -> rem(element,2) === 1 end)
# rem(1,2)=1    rem(2,2)=1    rem(3,2)=1    rem(4,2)=1    rem(5,2)=1
# true
iex> Enum.any?(enumerable, fn element -> rem(element,element) === 1 end)
# rem(1,1)=0    rem(2,2)=0    rem(3,3)=0    rem(4,4)=0    rem(5,5)=0
# true
iex> Enum.any?([false, false, false])
# false
iex> Enum.any?([false, true, false])
# true
iex> Enum.any?([])
# false

# at/2    at/3
# chunk/2    chunk/3    chunk/4

# chunk_by/2 = Se necessita agrupar uma coleção baseado em algo diferente do tamanho.e quando o retorno desta função muda, um novo grupo é iniciado e começa a criação do próximo
# chunk_by(enumerable, fun)
iex> Enum.chunk_by(["one", "two", "three", "four", "five", "six"], fn(x) -> String.length(x) end)
# [["one", "two"], ["three"], ["four", "five"], ["six"]]
iex> Enum.chunk_by(["one", "two", "six", "three", "four", "five"], fn(x) -> String.length(x) end)
# [["one", "two", "six"], ["three"], ["four", "five"]]

# chunk_every/2    chunk_every/3    chunk_every/4 = Se você necessita quebrar sua coleção em pequenos grupos chunk_every/2 , Retorna uma lista de listas contendo contagem cada um dos elementos, onde cada novo fragmento inicia os passos dos elementos no enumerable chunk_every/4.
# chunk_every(enumerable, count)
# chunk_every(enumerable, count, step)
# chunk_every(enumerable, count, step, leftover \\ [])
iex> Enum.chunk_every([1, 2, 3, 4, 5, 6], 2)
# [[1, 2], [3, 4], [5, 6]]
iex> Enum.chunk_every([1, 2, 3, 4, 5, 6], 3, 2)
# [[1, 2, 3], [3, 4, 5], [5, 6]]
iex> Enum.chunk_every([1, 2, 3, 4, 5, 6], 3, 2, :discard)
# [[1, 2, 3], [3, 4, 5]]
iex> Enum.chunk_every([1, 2, 3, 4, 5, 6], 3, 2, [7, 8, 9])
# [[1, 2, 3], [3, 4, 5], [5, 6, 7]]

# chunk_while/4
# concat/1    concat/2
# count/1    count/2
# dedup/1
# dedup_by/2
# drop/2
# drop_every/2
# drop_while/2

# each/2 =  iterar sobre uma coleção sem produzir um novo valor
# each(enumerable, fun)
iex> Enum.each(["one", "two", "three",1], fn(s) -> IO.puts(s) end)
# one
# two
# three
# 1
# :ok

# empty?/1
# fetch/2
# fetch!/2

# filter/2 = Filtra o enumerável, ou seja, retorna apenas os elementos para os quais a função retorna um valor verdadeiro.
# filter(enumerable, fun)
iex> Enum.filter([1, 2, 3, 4], fn(x) -> rem(x, 2) == 0 end)
# [2, 4]

# filter_map/3
# find/2    find/3
# find_index/2
# find_value/2    find_value/3
# flat_map/2
# flat_map_reduce/3
# frequencies/1
# frequencies_by/2
# group_by/2    group_by/3
# intersperse/2
# into/2    into/3
# join/1    join/2

# map/2 = Retorna uma lista em que cada elemento é o resultado da chamada de função para cada elementodo do enumerable.
# map(enumerable, fun)
iex> Enum.map([1, 2, 3], fn x -> x * 2 end)
# [2, 4, 6]
iex> Enum.map([a: 1, b: 2], fn {i, j} -> {i, -j} end)
# [a: -1, b: -2]

# map_every/3 = Retorna uma lista de resultados da chamada de função em cada elemento filho de enumerable, começando com o primeiro elemento.
# map_every(enumerable, nth, fun)
# Aplicar função a cada três itens
iex> Enum.map_every([1, 2, 3, 4, 5, 6, 7, 8], 3, fn x -> x + 1000 end)
# [1001, 2, 3, 1004, 5, 6, 1007, 8]

# map_intersperse/3
# map_join/2    map_join/3
# map_reduce/3

# max/1    max/2    max/3 = retorna o valor maximo de uma coleção
# max(enumerable)
# max(enumerable, fn -> default end)
iex> Enum.max([5, 3, 0, -1])
# 5
iex> Enum.max([], fn -> 0 end)
# 0

# max_by/2    max_by/3    max_by/4
# member?/2

# min/1    min/2    min/3 =  retorna o valor mínimo de uma coleção
# min(enumerable)
# min(enumerable, fn -> default end)
iex> Enum.min([5, 3, 0, -1])
# -1
iex> Enum.min([], fn -> 0 end)
# 0

# min_by/2    min_by/3    min_by/4
# min_max/1    min_max/2
# min_max_by/2    min_max_by/3    min_max_by/4
# partition/2
# random/1

# reduce/2    reduce/3 = Invoca a função para cada elemento no enumerável para reduzilo em um unico valor.
# reduce(enumerable, fun)
# reduce(enumerable, acc, fun)
iex> Enum.reduce([1, 2, 3], fn(x, acc) -> x + acc end)
# 6
iex> Enum.reduce([1, 2, 3], 10, fn(x, acc) -> x + acc end)
# 16
iex> Enum.reduce(["a","b","c"], "1", fn(x,acc)-> x <> acc end)
# "cba1"

# reduce_while/3
# reject/2
# reverse/1    reverse/2
# reverse_slice/3
# scan/2    scan/3
# shuffle/1
# slice/2    slice/3

# sort/1 = Classifica o enumerável de acordo com a ordem de termos de Erlang.
# sort(enumerable)
iex> Enum.sort([5, 6, 1, 3, -1, 4])
# [-1, 1, 3, 4, 5, 6]
# sort/2 = Classifica o enumerável pela função fornecida.
# sort(enumerable,fun)
iex(6)> Enum.sort([5, 6, 1, 3, -1, 4], fn (x, y) -> x > y end)
# [6, 5, 4, 3, 1, -1]

# sort_by/2    sort_by/3
# split/2
# split_while/2
# split_with/2
# sum/1
# take/2
# take_every/2
# take_random/2
# take_while/2
# to_list/1

# uniq/1    uniq/2 =  eliminar itens duplicados em nossas coleções:
# uniq(enumerable)
# uniq(enumerable, fun)
iex> Enum.uniq([1, 2, 3, 2, 1, 1, 1, 1, 1])
# [1, 2, 3]

# uniq_by/2 = remove os elementos duplicados da coleção retornados pela função.
# uniq_by(enumerable, fun)
iex> Enum.uniq_by([%{x: 1, y: 1}, %{x: 2, y: 1}, %{x: 3, y: 3}], fn coord -> coord.y end)
# [%{x: 1, y: 1}, %{x: 3, y: 3}]
iex> Enum.uniq_by([%{x: 1, y: 1}, %{x: 2, y: 1}, %{x: 3, y: 3}], fn coord -> coord.x end)
# [%{x: 1, y: 1}, %{x: 2, y: 1}, %{x: 3, y: 3}]
iex> Enum.uniq_by([{"1", :x}, {"2", :y}, {"1", :z}], fn {x, _} -> x end)
# [{"1", :x}, {"2", :y}]
iex> Enum.uniq_by([{"1", :x}, {"2", :y}, {"1", :z}], fn {_, y} -> y end)
# [{"1", :x}, {"2", :y}, {"1", :z}]

# unzip/1
# with_index/1    with_index/2
# zip/1    zip/2


# Enum usando o operador Capture (&)
# Abaixo está um exemplo típico da sintaxe padrão ao passar uma função anônima para Enum.map/2.
iex> Enum.map([1,2,3], fn number -> number + 3 end)
# [4, 5, 6]
# Agora implementamos o operador capture (&); capturando cada iterável da lista de números ([1,2,3])
# e atribuindo cada iterável à variável &1 à medida que é passado pela função de mapeamento.
iex> Enum.map([1,2,3], &(&1 + 3))
# [4, 5, 6]

# Primeiro, criamos uma função nomeada e a chamamos dentro da função anônima definida em Enum.map/2.
defmodule Adding do
  def plus_three(number), do: number + 3
end

iex>  Enum.map([1,2,3], fn number -> Adding.plus_three(number) end)
# [4, 5, 6]
# Em seguida, podemos refatorar para usar o operador Capture (&).
iex> Enum.map([1,2,3], &Adding.plus_three(&1))
# [4, 5, 6]
# Para obter a sintaxe mais limpa, podemos chamar diretamente a função nomeada sem capturar explicitamente a variável.
iex> Enum.map([1,2,3], &Adding.plus_three/1)
# [4, 5, 6]
