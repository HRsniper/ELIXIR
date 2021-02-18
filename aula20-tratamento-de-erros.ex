# Embora seja mais comum o retorno da tupla {:error, reason}, o Elixir suporta exceções.

# uma convenção em Elixir é criar uma função example/1 que retorna {:ok, result} e {:error, reason}
# e uma função separada example!/1 que retorna o result desempacotado ou levanta um erro.

raise(msg)
# Gera uma exceção.

# Se o argumento msg for binário, ele gerará uma exceção RuntimeError usando o argumento fornecido como mensagem.
iex> raise("Isso deu um erro")
# ** (RuntimeError) Isso deu um erro

# Se msg for um átomo, ele apenas chama raise/2  com o átomo como primeiro argumento e [] como segundo argumento.
iex> raise ArgumentError, message: "the argument value is invalid"
# ** (ArgumentError) the argument value is invalid
iex> raise ArgumentError, "the argument value is invalid"
# ** (ArgumentError) the argument value is invalid

# Se msg for uma estrutura de exceção, ela é gerada como está.
iex> try do
  1 + :foo
rescue
  x in [ArithmeticError] ->
    IO.puts("that was expected")
    raise x
end
# that was expected
# ** (ArithmeticError) bad argument in arithmetic expression

# Se msg for qualquer outra coisa, raise falhará com uma ArgumentError exceção.

# Se queremos especificar o tipo e mensagem.
iex> raise ArgumentError, message: "the argument value is invalid"
# ** (ArgumentError) the argument value is invalid
iex> raise ArgumentError, "the argument value is invalid"
# ** (ArgumentError) the argument value is invalid

try (args)
# Avalia as expressões fornecidas e lida com qualquer erro, saída ou lançamento que possa ter acontecido.
iex> try do
  # raise "opa temos uma erro!" # rescue
  # 1 == 2 # else
  throw(:some_value) # catch
rescue
  ArgumentError ->
    IO.puts("Invalid argument given")
catch
  value ->
    IO.puts("Caught #{inspect(value)}")
else
  value ->
    IO.puts("Success! The result was #{inspect(value)}")
after
  IO.puts("This is printed regardless if it failed or succeeded")
end

# A cláusula rescue é usada para tratar exceções.
# A cláusula catch pode ser usada para capturar valores lançados, saídas e erros.
# A cláusula else pode ser usada para controlar o fluxo com base no resultado da expressão.
# A cláusula after permite definir a lógica de limpeza que será chamada quando o bloco de código passado try/1
# for bem-sucedido e também quando um erro for gerado.

# detalhamento de try : https://hexdocs.pm/elixir/Kernel.SpecialForms.html#try/1

throw(term)
# joga uma exceção para frente

inspect(term, [palavras-chaves])
# Inspeciona o argumento fornecido de acordo com o protocolo Inspect.
# O segundo argumento é uma lista de palavras-chave com opções para controlar a inspeção.

# qualquer variável criada internamente try não pode ser acessada externamente

# quando precisamos criar erros personalizados. Criamos um novo erro com o macro defexception/1
# que aceita convenientemente a opção :message para definir uma mensagem de erro padrão
defexception (campos)
# Define uma exceção.
# As exceções são estruturas apoiadas por um módulo que implementa o comportamento Exception.

iex> defmodule ExampleError do
  defexception message: "an example error has occurred"
end

iex> try do
      raise ExampleError
     rescue
      e in ExampleError -> e
     end
# %ExampleError{message: "an example error has occurred"}

# O mecanismo de erro final que o Elixir fornece é o exit.
# Sinais de saída ocorrem sempre que um processo morre e são uma parte importante da tolerância
# a falhas do Elixir. Para sair explicitamente podemos usar exit/1:
iex> spawn_link fn -> exit("oh no") end
# ** (EXIT from #PID<0.101.0>) evaluator process exited with reason: "oh no"

iex> try do
      exit "oh no!"
     catch
      :exit, reason -> "exit blocked: reason #{reason}"
     end
# "exit blocked: reason oh no!"
