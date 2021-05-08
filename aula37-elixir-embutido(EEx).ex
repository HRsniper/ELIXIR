# Elixir tem EEx ou Embedded Elixir (Elixir embutido).
# Com EEx podemos embutir e avaliar código Elixir dentro das strings.

# A API EEX suporta trabalhar com cadeias de caracteres ou arquivos diretamente.
# A API está dividida em três componentes principais:
# - avaliação simples
# - definições de funções
# - compilação para AST

# Todas as funções neste módulo aceitam opções relacionadas ao EEx. Eles são:
# :file - o arquivo a ser usado no modelo. O padrão é o arquivo fornecido de onde o modelo é lido
#   ou para "nofile" ao compilar a partir de uma string.
# :line - a linha a ser usada como o início do modelo. O padrão é 1.
# :indentation - um inteiro adicionado à coluna após cada nova linha. O padrão é 0.
# :engine - o motor EEx a ser usado para compilação.Por padrão, EEx usa o EEx.SmartEngine que fornece
#   algumas conveniências além do simples EEx.Engine.
# :trim - se verdadeiro, corta os espaços em branco à esquerda/direita das tags de aspas até novas linhas.
#  Pelo menos uma nova linha é mantida. O padrão é falso.

# Etiquetas
# Por padrão o EEx.SmartEngine suporta quatro etiquetas(tags).
# <% expressão Elixir - alinhado com a saída %>
# <%= expressão Elixir - substitui com o resultado %>
# <%% EEx quotation - retorna o conteúdo do seu interior %>
# <%# Comentários - são ignorados no código fonte %>

# Todas expressões que desejamos imprimir devem usar o sinal de igualdade (=).
# É importante notar que enquanto outras linguagens de templates tratam cláusulas tipo if de forma especial,
# EEx não faz isso. exigem = para ter seu resultado impresso, sem = nada será impresso

# Para escapar de uma expressão EEx em uso EEx <%% content %>. ex.: <%%= x + 3 %> será processado como <%= x + 3 %>.

# Avaliação
# Usando eval_string/3 e eval_file/2, podemos realizar uma avaliação simples em relação a uma string
# ou ao conteúdo de um arquivo. Este é a API mais simples e mas lento uma vez que o código
# é interpretado e não compilado.
# eval_file(filename, bindings \\ [], options \\ [])
  # Obtém um nome de arquivo e avalia os valores usando as ligações.
# eval_string(source, bindings \\ [], options \\ [])
  # Obtém uma fonte de string e avalia os valores usando as ligações.

iex> EEx.eval_string "Hi, <%= name %>", [name: "Hercules"]
# "Hi, Hercules"

# aula37_eval_file.eex
Lendo do arquivo <%= key %>
iex> EEx.eval_file "aula37_eval_file.eex", key: "Hercules"
# "Lendo do arquivo Hercules"

# Definições
# O método mais rápido e preferido de usar EEx é embutir nosso modelo(template) em um módulo para que
# possa ser compilado.Para isso precisamos do nosso template em tempo de compilação(no momento da compilação)
# e dos macros function_from_string/5 e function_from_file/5.
# function_from_file(kind, name, file, args \\ [], options \\ [])
  # Gera uma definição de função a partir do conteúdo do arquivo.
# function_from_string(kind, name, source, args \\ [], options \\ [])
  # Gera uma definição de função a partir da string.
# tipo(kind) (:def ou :defp) deve ser fornecido, o nome da função, seus argumentos e as opções de compilação.
iex> defmodule Example do
  require EEx
  EEx.function_from_file(:def, :from_file, "aula37_eval_file.eex", [:key])
end
iex> Example.from_file("Sean")
# "Lendo do arquivo Sean"

iex> defmodule Example do
  require EEx
  EEx.function_from_file(:def, :from_file, "aula37_eval_file.eex", [:key])
  EEx.function_from_string(:def, :from_string, "Hi, <%= name %>", [:name])
end
iex> Example.from_string("Frodo")
# "Hi, Frodo"

# Compilação
# Por último, EEx nos fornece uma maneira de gerar Elixir AST diretamente a partir de uma string
# ou arquivo usando compile_string/2 ou compile_file/2.
# Esta API é usada principalmente pelas APIs acima mencionadas, mas está disponível caso deseje implementar
# seu próprio tratamento de Elixir embutido.
# compile_file (filename, options \\ [])
  # Obtém um filename e gera uma expressão entre aspas que pode ser avaliada pelo Elixir ou compilada para uma função.
# compile_string (source, options \\ [])
  # Obtém uma string source e gera uma expressão entre aspas que pode ser avaliada pelo Elixir ou compilada para uma função.

iex> quoted = EEx.compile_file("aula37_eval_file.eex", [trim: true])
# {:__block__, [],
#  [
#    {:=, [],
#     [
#       {:arg0, [], EEx.Engine},
#       {{:., [], [{:__aliases__, [alias: false], [:String, :Chars]}, :to_string]},
#        [], [{:key, [line: 1], nil}]}
#     ]},
#    {:<<>>, [],
#     [
#       "Lendo do arquivo ",
#       {:"::", [], [{:arg0, [], EEx.Engine}, {:binary, [], EEx.Engine}]}
#     ]}
#  ]}
iex> {result, bindings} = Code.eval_quoted(quoted, key: "Gandalf")
# {"Lendo do arquivo Gandalf", [{:key, "Gandalf"}, {{:arg0, EEx.Engine}, "Gandalf"}]}
iex> result
# "Lendo do arquivo Gandalf"
iex> bindings
# [{:key, "Gandalf"}, {{:arg0, EEx.Engine}, "Gandalf"}]

iex> quoted = EEx.compile_string("<%= a + b %>")
iex> {result, _bindings} = Code.eval_quoted(quoted, a: 1, b: 2)
iex> result
# 3

# IF
iex> EEx.eval_string("<%= if true do %>A truthful statement <%=name%><% else %>A false statement <%=name%><% end %>", [name: "Hercules"])
# "A truthful statement Hercules"
iex> EEx.eval_string("<%= if false do %>A truthful statement <%=name%><% else %>A false statement <%=name%><% end %>", [name: "Hercules"])
# "A false statement Hercules"

# Code
# Utilitários para gerenciar compilação de código, avaliação de código e carregamento de código.

# eval_quoted(quoted, binding \\ [], opts \\ [])
# Avalia os conteúdos citados(entre aspas).

# Aviso: chamar esta função dentro de uma macro é considerada uma prática inadequada,
# pois tentará avaliar os valores de tempo de execução em tempo de compilação.
# Os argumentos de macro são normalmente transformados retirando-os das aspas
# nas expressões entre aspas retornadas (em vez de avaliadas).

# Engine
# Por padrão, o Elixir usa o EEx.SmartEngine, que inclui suporte para atribuições (como @name)
# aula37_@eval_file.eex
Lendo do arquivo <%= @key %>
iex> EEx.eval_string "Hi, <%= @name %>", assigns: [name: "Sean"]
# "Hi, Sean"
iex> defmodule Example do
  require EEx
  EEx.function_from_file(:def, :from_file, "aula37_@eval_file.eex", [:assigns])
end
iex> Example.from_file(key: "Algum nome qualquer")
# "Lendo do arquivo Algum nome qualquer"

# As atribuições do EEx.SmartEngine são úteis porque as atribuições podem ser alteradas sem exigir
# a compilação do modelo.
# Se estiver interessado em escrever o seu próprio motor? Confira o comportamento EEx.Engine
# para ver o que é necessário.
