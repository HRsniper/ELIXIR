# IEx é um REPL, mas possui muitas funcionalidades avançadas que podem tornar a vida mais fácil,
# seja explorando um novo código ou desenvolvendo seu próprio trabalho a medida que avança.
# Há uma enorme quantidade de helpers embutidos.

# IEx.Helpers
# b/1 - imprime informações de callbacks e documentos para um determinado módulo
# c/1 - compila um arquivo
# c/2 - compila um arquivo e grava o bytecode no caminho fornecido
# cd/1 - muda o diretório atual
# clear/0 - limpa a tela
# exports/1 - mostra todas as exportações (funções + macros) em um módulo
# flush/0 - libera todas as mensagens enviadas para o shell
# h/0 - imprime esta mensagem de ajuda
# h/1 - imprime ajuda para o módulo, função ou macro fornecido
# i/0 - imprime informações sobre o último valor
# i/1 - imprime informações sobre o termo fornecido
# ls/0 - lista o conteúdo do diretório atual
# ls/1 - lista o conteúdo do diretório especificado
# open/1 - abre o código-fonte para o determinado módulo ou função em seu editor
# pid/1 - cria um PID a partir de uma string
# pid/3 - cria um PID com os 3 argumentos inteiros passados
# port/1 - cria uma porta a partir de uma string
# port/2 - cria uma porta com os 2 inteiros não negativos passados
# ref/1 - cria uma referência a partir de uma string
# ref/4 - cria uma referência com os 4 argumentos inteiros passados
# pwd/0 - imprime o diretório de trabalho atual
# r/1 - recompila o arquivo fonte do módulo fornecido
# recompile/0 - recompila o projeto atual
# runtime_info/0 - imprime informações de tempo de execução (versões, uso de memória, estatísticas)
# v/0 - recupera o último valor do histórico
# v/1 - recupera o enésimo valor do histórico

# tem outros funções : https://hexdocs.pm/iex/IEx.Helpers.html#content


# criando um iex helper
# Toda vez que o IEx inicia, ele irá procurar por um arquivo de configuração .iex.exs.
# Se não estiver presente no diretório atual, então o (~/.iex.exs) do diretório home do usuário será
# usado como alternativa.

# no diretório onde criou o .iex.exs abre um shell
iex> IExHelpers.whats_this?("a string")
# "Type: Binary"
iex> IExHelpers.whats_this?(%{})
# "Type: Unknown"
iex> IExHelpers.whats_this?(:test)
# "Type: Atom"
iex> IExHelpers.whats_this?(nil)
# "Type: Nil"
iex> IExHelpers.whats_this?(true)
# "Type: Boolean"

# Como podemos ver não precisamos fazer nada de especial para requerer ou importar nossos helpers, IEx trata disso para nós.

