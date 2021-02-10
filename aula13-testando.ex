# O framework de testes integrado do Elixir é o ExUnit, isto inclui tudo o que precisamos para testar
# exaustivamente o nosso código.
# é importante notar que testes são implementados como scripts Elixir, por isso precisamos usar a extensão
# de arquivo .exs
# Antes de podermos executar nossos testes nós precisamos iniciar o ExUnit com ExUnit.start(),
# este é mais comumente feito em test/test_helper.exs.

# Quando geramos nosso projeto de exemplo, o mix foi útil o suficiente para criar um teste simples para nós,
# podemos encontrá-lo em test/example_test.exs:

# executando testes 'mix test'
cli> mix test
# ..
# Finished in 0.03 seconds
# 1 doctest, 1 test, 0 failures
# Randomized with seed 165000

# assert
# Se você escreveu testes antes, então você está familiarizado com assert;
# em alguns frameworks should ou expect preenchem o papel de assert.
# Usamos o assert macro para testar se a expressão é verdadeira.
# No caso em que não é, um erro vai ser levantado e os nossos testes irão falhar

# ExUnit nos diz exatamente onde nossos asserts falharam, qual era o valor esperado e qual o valor atual.

# refute
# refute é para assert como unless é para if.
# Use refute quando você quiser garantir que uma declaração é sempre falsa.

# assert_raise
# Às vezes pode ser necessário afirmar que um erro foi levantado, podemos fazer isso com assert_raise.

# assert_receive
# Em Elixir, as aplicações consistem em atores/processos que enviam mensagens um para o outro,
# portanto muitas vezes você quer testar mensagens sendo enviadas.
# Afirma que um padrão de correspondência de mensagem foi ou será
# recebido dentro do período de tempo limite, especificado em milissegundos.

defmodule SendingProcess do
  def run(pid) do
    send(pid, :ping)
  end
end

defmodule TestReceive do
  use ExUnit.Case

  test "receives ping" do
    SendingProcess.run(self())
    assert_received :ping
  end
end

# assert_received
# Afirma que uma correspondência de mensagem pattern foi recebida e está na caixa de correio do processo atual.
# não espera mensagens como assert_receive que você pode especificar um tempo limite.

# capture_io and capture_log
# Capturar uma saída da aplicação é possível com ExUnit.CaptureIO sem mudar a aplicação original.
# Basta passar a função gerando a saída;

defmodule OutputTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "outputs Hello World" do
    assert capture_io(fn -> IO.puts("Hello World") end) == "Hello World\n"
  end
end

# ExUnit.CaptureLog é o equivalente para capturar a saída de Logger.

# Configuração de Teste
# Em alguns casos, pode ser necessária a realização de configuração antes de nossos testes.
# Para fazer isso acontecer, nós podemos usar as macros setup e setup_all.
# 'setup' irá ser executado antes de cada teste, e 'setup_all' uma vez antes de todos de testes.
# Espera-se que eles vão retornar uma tupla de {:ok, state}, o estado estará disponível para os nossos testes.

# state
# Todos os testes começam com um estado de nil.Um teste concluído pode estar em um dos cinco estados:
# Passed = Aprovado (também representado por nil)
#   Failed = Falhou
#   Skipped = Ignorado (via @tag :skip)
#   Excluded = Excluído (via :exclude filters)
#   Invalid = Inválido (quando setup_all falha)
