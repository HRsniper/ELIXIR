# Mix é uma ferramenta de construção que fornece tarefas para criar, compilar e testar projetos Elixir,
#   gerenciar suas dependências e muito mais.

cli> mix new example

# * creating README.md
# * creating .formatter.exs
# * creating .gitignore
# * creating mix.exs
# * creating lib
# * creating lib/example.ex
# * creating test
# * creating test/test_helper.exs
# * creating test/example_test.exs

# Your Mix project was created successfully.

# 'mix.exs'. Aqui nós configuramos nossa aplicação, dependências, ambiente e versão.

# A seção 'project'. Aqui nós definimos o nome da nossa aplicação (app), especificamos nossa versão (version),
# versão do Elixir (elixir), e finalmente nossas dependências (deps).
# A seção 'application' é usada durante a geração do nosso arquivo de aplicação
# A seção 'deps' contem nossas dependências


# Pode ser necessário a utilização do iex dentro do contexto da nossa aplicação.
# Felizmente para nós, mix torna isso fácil. Com a nossa aplicação compilada podemos começar uma nova seção iex:
cli>  iex -S mix
# Iniciando iex desta forma, carrega sua aplicação e dependências no atual ambiente de execução.

# Mix é inteligente e irá compilar as alterações quando necessário, mas ainda pode
# ser necessário explicitamente compilar o seu projeto.

# Para compilar um projeto mix nós apenas temos que executar 'mix compile' em nossa base do diretório.

# Nota: As tarefas do mix de um projeto estão disponíveis apenas no diretório raiz do projeto,
# apenas as tarefas globais do mix estão disponíveis em todos os projetos.
cli> mix compile

# Quando compilamos um projeto, mix cria um diretório _build para os nossos artefatos.
# Se olharmos dentro de _build veremos a aplicação compilada: example.app.

# Gestão de dependências, nosso projeto não tem nenhuma dependência, mas em breve irá ter,
# por isso iremos seguir em frente e cobrir a definição e busca de dependências.

# Para adicionar uma nova dependência, primeiro precisamos adicioná-la ao nosso mix.exs na seção deps.
# Nossa lista de dependência é composta por tuplas com 2 valores obrigatórios e um opcional:
#  O nome do pacote como um atom, a versão como string e opções opcionais.

{:phoenix, "~> 1.1 or ~> 1.2"},
{:phoenix_html, "~> 2.3"},
{:cowboy, "~> 1.0", only: [:dev, :test]},
{:slime, "~> 0.14"}
# adicionar em mix.exs ,a dependência cowboy é apenas necessária durante o desenvolvimento e teste.

# https://hex.pm/ para procurar dependências

# Uma vez que tenhamos definido nossas dependências, agora buscamos estas dependências.
# Isso é análogo ao 'bundle install':
cli> mix deps.get

# Ambientes Mix, bem como Bundler, suporta ambientes diferentes. Naturalmente mix trabalha com três ambientes:
#  :dev — O ambiente padrão.
#  :test — Usado por mix test.
#  :prod — Usado quando nós enviamos a nossa aplicação para produção.

# O ambiente atual pode ser acessado usando Mix.env. Como esperado, o ambiente pode ser alterado através
# da variável de ambiente MIX_ENV:
cli> iex -S mix
cli> Mix.env()
# :dev
cli> MIX_ENV=prod mix compile
