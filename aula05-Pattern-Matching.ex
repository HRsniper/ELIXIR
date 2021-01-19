# Pattern matching é uma poderosa parte de Elixir que nos permite procurar padrões simples em valores,
# estruturas de dados, e até funções.

# Operador Match Você está preparado para ficar um pouco confuso? Em Elixir,
# o operador = é na verdade o nosso operador match, comparável ao sinal de igualdade da matemática.
# Quando usado, a expressão inteira se torna uma equação e faz com que Elixir combine os valores
# do lado esquerdo com os valores do lado direito da expressão. Se a comparação for bem sucedida,
# o valor da equação é retornado. Se não, um erro é lançado. Vejamos a seguir:
iex> x = 1
# 1
Agora vamos tentar a simples correspondência:
iex> 1 = x
# 1
iex> 2 = x
# ** (MatchError) no match of right hand side value: 1
iex> y=:x
# :x
iex> :x=y
# :x
iex> :x=1
# ** (MatchError) no match of right hand side value: 1
iex> list = [1, 2, 3]
iex> [1, 2, 3] = list
# [1, 2, 3]
iex> [] = list
# ** (MatchError) no match of right hand side value: [1, 2, 3]
iex> tuple = {:ok, "Successful!"}
iex> {:ok, value} = tuple
# {:ok, "Successful!"}
iex> value
# "Successful!"
iex> {} = tuple
# ** (MatchError) no match of right hand side value: {:ok, "Successful!"}

# Operador Pin Acabamos de aprender que o operador match manuseia atribuições quando o
# lado esquerdo da associação é uma variável. Em alguns casos este comportamento de reassociação de variável
# é algo não desejável. Para estas situações, nós temos o operador pin:^.

# Quando fixamos a variável em associação ao valor existente ao invés de reassociar a um novo valor

iex> x = 1
1
iex> ^x = 2
# ** (MatchError) no match of right hand side value: 2
iex> {x, ^x} = {2, 1}
# {2, 1}
iex> x
# 2
iex> ^x
# ** (CompileError) iex:20: cannot use ^x outside of match clauses
iex> key = "hello"
# "hello"
iex> %{^key => value} = %{"hello" => "world"}
# %{"hello" => "world"}
iex> value
# "world"
iex> %{^key => value} = %{:hello => "world"}
# ** (MatchError) no match of right hand side value: %{hello: "world"}
iex> %{"hello" => value} = %{:hello => "world"}
# ** (MatchError) no match of right hand side value: %{hello: "world"}

iex> greeting = "Hello"
# "Hello"
iex> greet = fn
...>   (^greeting, name) -> "Hi #{name}"
...>   (greeting, name) -> "#{greeting}, #{name}"
...> end
#Function<12.54118792/2 in :erl_eval.expr/5>
iex> greet.("Hello", "Sean")
# "Hi Sean"
iex> greet.("Hellooo", "Sean")
# "Helloo, Sean"

# Note que "Hellooo", a reassociação de greeting para "Hellooo"
# só acontece dentro de uma função. Fora da função, greeting continua sendo "Hello".
iex> greeting
# "Hello"
