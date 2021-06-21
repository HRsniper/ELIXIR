# Bugs são problemas comuns em qualquer projeto, é por isso que precisamos da depuração.
# A ferramenta mais direta que nós temos para depurar código Elixir é o IEx
# Mas não se deixa enganar por sua simplicidade - você pode resolver a maioria dos
# problemas da sua aplicação com ele. IEx significa Elixir's Interactive Shell.

iex> defmodule TestMod do
  def sum([a, b]) do
    b = 0

    a + b
  end
end

iex> IO.puts(TestMod.sum([34, 65]))
# 34
# :ok

# vamos criar um arquivo aula40_test.exs com esse código e executar
$ elixir aula40_test.exs
# warning: variable "b" is unused (if the variable is not meant to be used, prefix it with an underscore)
#   aula40_test.exs:2: TestMod.sum/1
# 34

# vamos preparar nosso código paa receber  a depuração.
# Insira `require IEx; IEx.pry` depois da linha com `b = 0` e executamos o código novamente.

# em aula40_test.exs
...
  require IEx; IEx.pry
...

$ elixir aula40_test.exs
# warning: variable "b" is unused (if the variable is not meant to be used, prefix it with an underscore)
#   aula40_test.exs:2: TestMod.sum/1

# Cannot pry #PID<0.92.0> at TestMod.sum/1 (aula40_test.exs:5). Is an IEx shell running?
#   If you are using Windows, you may need to start IEx with the --werl option.
# 34

# Você deve perceber uma mensagem Cannot pry.
# Ao executar um aplicativo, como de costume, o IEx emite essa mensagem em vez de bloquear a execução do programa.
# Para executá-lo corretamente, você precisa preceder seu comando com 'iex -S'.
# O que isso faz é executar o 'mix' dentro do comando 'iex' para que execute o aplicativo em um modo especial,
# de forma que as chamadas para 'IEx.pry' parem a execução do aplicativo.
# Por exemplo, 'iex -S mix phx.server' para depurar seu aplicativo Phoenix.
# Em nosso caso, será 'iex -r aula40_test.exs' para exigir o arquivo.

# -r recompila arquivo de origem do módulo fornecido.
$ iex -r aula40_test.exs
# warning: variable "b" is unused (if the variable is not meant to be used, prefix it with an underscore)
#   aula40_test.exs:2: TestMod.sum/1

# Request to pry #PID<0.101.0> at TestMod.sum/1 (aula40_test.exs:5)
  # 3:     b = 0
  # 4:
  # 5:     require IEx; IEx.pry
  # 6:
  # 7:     a + b

# Allow? [Yn] y
pry> a
# 34
pry> b
# 0
pry> a+b
# 34
pry> continue
# 34

# Para sair do IEx, você pode pressionar Ctrl + C duas vezes para sair do aplicativo
# ou digite 'continue' para seguir para o próximo breakpoint.

# é possível executar qualquer código Elixir. Entretanto, a limitação é que você não pode modificar
# nenhuma variável do código existente, devido a imutabilidade da linguagem.
# Apesar disso, você pode obter todos os valores das variáveis e executar qualquer computação.
# Nesse caso, o bug seria em 'b' sendo reatribuído para 0, e a função 'sum' sendo afetada como resultado.
# o elixir já capturou esse bug na primeira execução, mas isso é um exemplo de como depuração funciona!

# IEx.Helpers
# Uma das partes mais chatas de trabalhar com o IEx é que ele não tem nenhum histórico de comandos
# que você usou em execuções anteriores.
# Para resolver esse problema, existe uma subseção na Documentação do IEx (https://hexdocs.pm/iex/IEx.html#module-shell-history),
# onde você pode achar a solução de acordo com sua plataforma.
# Você também pode checar a lista com o resto dos utilitários disponíveis na Documentação de Helpers do IEx.
# (https://hexdocs.pm/iex/IEx.Helpers.html#summary)

# Dialyxir e Dialyzer
# O Dialyzer (DIscrepancy AnaLYZer for ERlang), é uma ferramenta para análise de código estático.
# Em outras palavras eles leem e analisam mas não rodam o código.
# Exemplo: procurando por alguns bugs, códigos mortos, desnecessários ou inacessíveis.

# O Dialyxir é uma tarefa mix para simplificar o uso do Dialyzer em Elixir.

# Ferramentas de especificação como o Dialyzer ajudam a entender melhor o código.
# Ao contrário da documentação, que é legível por humanos (se apenas existe e é bem escrito),
# @spec usa uma sintaxe mais formal e que pode ser entendida pela máquina.

# criamos um projeto
$ mix new aula40_debugging
# e adicionamos a dependência ao arquivo mix.exs
defp deps do
  [
    {:dialyxir, "~> 1.1", only: [:dev], runtime: false}
  ]
end

$ mix do deps.get, deps.compile

# Demora alguns minutos para que o processo seja concluído
$ mix dialyzer
# se o PLT (Persistent Lookup Table) do Dialyzer nao tiver sido criado, ele criara
# o PLT precisa ser refeito todo vez após a instalação de uma nova versão do Erlang ou Elixir.
# 'mix dialyzer --plt' Inicia o PLT Core Build

# Executar o dialyzer de tarefa 'mix' por padrão cria vários arquivos PLT:
# Um arquivo do núcleo Erlang em $MIX_HOME/dialyxir_erlang-[OTP Version].plt
# Um arquivo do núcleo Elixir em $MIX_HOME/dialyxir_erlang-[OTP Version]_elixir-[Elixir Version].plt
# Um arquivo específico do ambiente do projeto em _build/$ENV/dialyze_erlang-[OTP Version]_elixir-[Elixir Version]_deps-dev.plt

# Quando o processo terminar ia receber uma mensagem parecida com essa
# done in 9m49.98s

# em lib\aula40_debugging.ex
@spec sum_times(integer) :: integer
def sum_times(a) do
  [1, 2, 3]
  |> Enum.map(fn el -> el * a end)
  |> Enum.sum()
end

$ mix dialyzer
# Total errors: 1, Skipped: 0, Unnecessary Skips: 0
# done in 0m1.99s

# A mensagem do Dialyzer é clara: o tipo de retorno da nossa função sum_times/1 é diferente do declarado em @spec.
# Isso ocorre porque Enum.sum/1 retorna um number e não um integer, mas o tipo de retorno de sum_times/1 é integer.
# Como number não é integer, obtemos um erro. Como podemos consertar isso? Precisamos usar a função round/1
# para mudar nosso number para integer.

# em lib\aula40_debugging.ex
...
  |> Enum.sum()
  |> round
...

$ mix dialyzer
# Total errors: 0, Skipped: 0, Unnecessary Skips: 0
# done in 0m1.99s
# done (passed successfully)

# O uso de especificações com ferramentas para realizar a análise de código estático
# nos ajuda a fazer com que o código seja auto-testado e contenha menos bugs.

# Depuração
# Às vezes, a análise estática de código não é suficiente. Pode ser necessário entender o fluxo de execução
# para encontrar bugs. A maneira mais simples é colocar as instruções de saída em nosso código como IO.puts/2
# para rastrear valores e fluxo de código, mas essa técnica é primitiva e tem limitações. Felizmente para nós,
# podemos usar o Erlang debugger para depurar nosso código Elixir.

# em lib\aula40_debugging.ex
...
  def cpu_burns(a, b, c) do
    x = a * 2
    y = b * 3
    z = c * 5

    x + y + z
  end
...

$ iex -S mix

# E então rodamos o debugger
iex> :debugger.start()
# {:ok, #PID<0.202.0>}

# O modulo :debugger do Erlang fornece acesso ao depurador. Podemos usar a função start/1 para configurá-lo,
# Um arquivo de configuração externo pode ser usado passando o caminho do arquivo.
  # Se o argumento for :local ou :global, o depurador vai
  #   :global – o depurador irá interpretar o código em todos os nós conhecidos. Esse é o valor padrão.
  #   :local – o depurador irá interpretar o código somente no nó atual.

# O próximo passo é anexar nosso módulo ao depurador
iex> :int.ni(Aula40Debugging)
# {:module, Aula40Debugging}

# O modulo :int é um intérprete que nos dá a capacidade de criar pontos de interrupção
# e passo através da execução do código.

# O :int Interpreta o(s) módulo(s) especificado(s). 'i/1' interpreta o módulo apenas no nó atual.
# 'ni/1' interpreta o módulo em todos os nós conhecidos.
# Um módulo pode ser especificado por seu nome de módulo (átomo) ou nome de arquivo.
# Se especificado por seu nome de módulo, o código do objeto 'Module.beam' é pesquisado no caminho atual.
# O código-fonte 'Module.erl' é pesquisado primeiro no mesmo diretório do código-objeto e,
# em seguida, em um diretório-fonte próximo a ele.

# i(AbsModule) -> {module,Module} | error
# i(AbsModules) -> ok
# ni(AbsModule) -> {module,Module} | error
# ni(AbsModules) -> ok

# Quando você inicia o depurador, você verá uma nova janela de monitoramento
# Depois de ter anexado o nosso módulo para o depurador estará disponível no menu à esquerda
# como 'Elixir.Aula40Debugging'.

# Criando breakpoints
# Um breakpoint é um ponto no código onde a execução será interrompida. Temos duas maneiras de criar breakpoint
# ':int.break/2' em nosso código ou com a IU do depurador.

break(Module, Line) -> ok | {error,break_exists}

iex> :int.break(Aula40Debugging, 15)
# :ok
# Isso define um breakpoint na linha 15 do nosso módulo.

# Agora, se chamarmos nossa função
iex> Aula40Debugging.cpu_burns(1, 1, 1)
# 10
# A execução será pausada no IEx e a janela do depurador deverá ter criado um novo PID
# Aparecerá uma janela adicional com o nosso código fonte,
# caso ela nao abrir click duas vez no PID com status 'break' com a informação da linha desejada.

# Nesta janela, podemos procurar o valor das variáveis, avançar para a próxima linha ou avaliar expressões.
# :int.disable_break/2 pode ser chamado para desabilitar um breakpoint
disable_break(Module, Line) -> ok
# Para reativar um breakpoint, podemos chamar :int.enable_break/2.
enable_break(Module, Line) -> ok
# ou podemos remover um breakpoint.
delete_break(Module, Line) -> ok
iex> :int.delete_break(Aula40Debugging, 15)
# :ok

# As mesmas operações estão disponíveis na janela do depurador. No menu superior, Break,
# nós podemos selecionar Line Break e configurar o breakpoint.
# Se selecionarmos uma linha que não contenha código, os pontos de interrupção serão ignorados,
# mas ele aparecerá na janela do depurador.

# Existem três tipos de breakpoint
# Breakpoint de linha - o depurador suspende a execução quando chegamos à linha, com a configuração :int.break/2.
# Breakpoint condicional — semelhante ao breakpoint de linha, mas o depurador suspende
#   somente quando a condição especificada for atingida, estes são configurados usando :int.get_binding/2.
  get_binding(Var, Bindings) -> {value,Value} | unbound
# Breakpoint da função - o depurador irá suspender na primeira linha de uma função,
#   configurada usando :int.break_in/3
  break_in(Module, Name, Arity) -> ok | {error,function_not_found}
