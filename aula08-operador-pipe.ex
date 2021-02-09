# O operador pipe |> passa o resultado de uma expressão como o primeiro parâmetro de outra expressão.

# Programação pode se tornar algo bem confuso. Tão confuso que o fato de chamadas em funções podem ficar
#   tão incorporadas a outras chamadas de função, tornando-se muito difícil de seguir.
foo(bar(baz(new_function(other_function()))))

# Aqui, nós estamos passando o valor other_function/0 para new_function/1, e new_function/1 para baz/1,
#   baz/1 para bar/1, e finalmente o resultado de bar/1 para foo/1.
#   Elixir possui um modo pragmático para esse caos sintático, permitindo-nos a utilização do operador pipe.
#   recebe o resultado de uma expressão e passa ele adiante.
other_function() |> new_function() |> baz() |> bar() |> foo()
# O pipe pega o resultado da esquerda e o passa para o lado direito.

# Tokenize String (vagamente)
iex> "Elixir Functional Programing Language" |> String.split()
# ["Elixir", "Functional", "Programing", "Language"]
  iex> String.split("Elixir Functional Programing Language")
  # ["Elixir", "Functional", "Programing", "Language"]

# Converte palavras para letras maiúsculas
iex> "Elixir Functional Programing Language" |> String.upcase() |> String.split()
# ["ELIXIR", "FUNCTIONAL", "PROGRAMING", "LANGUAGE"]

# Checa terminação de palavra
iex> "elixir" |> String.ends_with?("ixir")
# true

