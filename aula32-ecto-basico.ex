# Ecto é um projeto oficial do Elixir que fornece uma camada de banco de dados e linguagem integrada para consultas.
# Com Ecto podemos criar migrações, definir esquemas, inserir e atualizar registros, e fazer consultas.

# Adaptadores
# https://hexdocs.pm/ecto_sql/Ecto.Adapters.SQL.html
# O Ecto suporta diferentes banco de dados através do uso de adaptadores.
# Por padrão suporta os seguintes adaptadores:
  # Ecto.Adapters.Postgres para Postgres
  # Ecto.Adapters.MyXQL para MySQL
  # Ecto.Adapters.Tds para SQLServer

# vamos configurar o Ecto para usar o adaptador do PostgreSQL.


# para começar, cobriremos três partes do Ecto:
  # Repositório (Repo): provê a interface com nosso banco de dados, incluindo a conexão.
  # Migrações (Migration): um mecanismo para criar, modificar e destruir tabelas e índices no banco de dados.
  # Esquemas (Schema): estruturas especiais para representar linhas em tabelas no banco de dados.

# iniciaremos a criação da aplicação com uma árvore de supervisão:
$ mix new company --sup

# Adicione o ecto e o postgrex como dependências no seu mix.exs
# https://hex.pm/packages/ecto_sql
  {:ecto_sql, "~> 3.6"},
# https://hex.pm/packages/postgrex
  {:postgrex, "~> 0.15.8"}

# Depois, busque as dependências usando:
$ mix deps.get

# Criando um repositório
# Um repositório no Ecto mapeia a um banco de dados, como o nosso banco no Postgres.
# Toda a comunicação ao banco de dados será feita através desse repositório.
  # https://hexdocs.pm/ecto/Mix.Tasks.Ecto.Gen.Repo.html#content
$ mix ecto.gen.repo -r Company.Repo

# Essa tarefa irá gerar toda a configuração requirida para conectar a um banco de dados em config/config.exs,
# incluindo a configuração do adaptador.

# Essa é a configuração do nosso banco de dados Company
config :company, Company.Repo,
  database: "company_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

# E também gera um módulo chamado Company.Repo em lib/company/repo.ex
defmodule Company.Repo do
  use Ecto.Repo,
    otp_app: :company,
    adapter: Ecto.Adapters.Postgres
end
# Nós utilizaremos o módulo Company.Repo para consultar o banco de dados.
# Nós também dizemos a esse módulo para encontrar suas configurações na aplicação :company
# e selecionamos o adaptador Ecto.Adapters.Postgres.

# Cada repositório no Ecto define uma função start_link/0 que precisa ser chamada antes
# de usar o repositório. Em geral, essa função não é chamada diretamente, mas usada como parte da
# árvore de supervisão do aplicativo.

# também iremos configurar o Company.Repo como supervisor de nossa árvore de supervisão
# em lib/company/application.ex. Isso irá iniciar o processo do Ecto assim que nossa aplicação iniciar.
children = [
  {Company.Repo, []}
]

# Depois disso, precisamos adicionar a seguinte linha no nosso config/config.exs:
config :company,
  ecto_repos: [Company.Repo]
# Isso irá permitir à nossa aplicação rodar tarefas mix do Ecto a partir da linha de comando.

# Agora podemos criar o banco de dados no PostgreSQL
# Ecto vai utilizar a informação no arquivo config/config.exs para determinar como se conectar ao Postgres
# e como nomear o banco de dados.
$ mix ecto.create
  # The database for Company.Repo has been created

# Se você receber algum erro, certifique-se de que os dados de
# configuração (username, password) seja igual a da sua instância do postgres que está rodando.

# usa algum software para consultar visualmente se o banco fui criado, no windows quando instala o postgres,
#  vem junto o pgAdmin, vamos utiliza-lo para ver se o banco esta correto.

# Migrações
# Para criar e modificar tabelas no banco de dados, utilizamos as migrações do Ecto.
# Cada migração descreve uma série de ações para serem realizadas no nosso banco,
# como quais tabelas criar ou atualizar.

# Como nosso banco de dados ainda não tem tabelas, precisaremos criar uma migração para adicionar algumas.
# A convenção em Ecto é pluralizar nossas tabelas, portanto, para a aplicação,
# precisaremos de uma tabela de pessoas (employees), então vamos começar com nossas migrações.

$ mix ecto.gen.migration create_employees
  # creating priv/repo/migrations
  # creating priv/repo/migrations/20210407193852_create_employees.exs
# Isso irá gerar um novo arquivo na pasta priv/repo/migrations contendo uma timestamp no nome.

# Se abrirmos a migração, veremos algo assim:
defmodule Company.Repo.Migrations.Createemployees do
  use Ecto.Migration

  def change do

  end
end

# As migrações normalmente fornecem duas operações: `up` e` down`,
# A função up/0 é responsável por migrar a criação do seu banco de dados para frente.
# A função down/0 é executada sempre que você deseja reverter.
# A função down/0 deve sempre fazer o oposto de up/0.

# Ter que escrever funções up/0 e down/0 para cada migração é entediante e sujeito a erros.
# Por esta razão, o Ecto permite que você defina um retorno de chamada change/0
# com todo o código que você deseja executar ao migrar e o Ecto descobrirá automaticamente o down/0 para você.


# Vamos modificar função change/0 para criar uma nova tabela employees com os campos name e age:
  def change do
    create table(:employees) do
      add :name, :string, null: false
      add :age, :integer, default: 0
      # Adicionalmente, nós incluímos null: false e default: 0 como opções.
  end

# create(index)
  # Cria um dos seguintes: um index, uma tabela com apenas a chave primária :id, uma constraint
# create(object, list)
  # Cria uma tabela.
# table(name, opts \\ [])
  # Retorna uma estrutura de tabela que pode ser fornecida para create/2, alter/2, drop/1, etc.
# add(column, type, opts \\ [])
  # Adiciona uma coluna ao criar ou alterar uma tabela.

# Agora vamos Executar as migrações do repositório
$ mix ecto.migrate
  # hh:mm:ss.ms [info]  == Running 20210407193852 Company.Repo.Migrations.CreateEmployees.change/0 forward
  # hh:mm:ss.ms [info]  create table employees
  # hh:mm:ss.ms [info]  == Migrated 20210407193852 in 0.1s

# Exibe o status de migração do repositório
$ mix ecto.migrations

# use um software para ver visualmente se a tabela foi criada corretamente, se quiser

# Esquemas
# Agora que criamos nossa tabela inicial, precisamos dizer mais sobre ela ao Ecto,
# e parte de como fazemos isso é através de esquemas.
# Um esquema é um módulo que define um mapeando dos campos de uma tabela.

# Enquanto nas tabelas utilizamos o plural, no esquema tipicamente se utiliza o singular.
# Então criamos um esquema Employee para nossa tabela.

# Criamos ele em lib/company/employee.ex
$ touch lib/company/employee.ex

# em lib/company/employee.ex
defmodule Company.Employee do
  use Ecto.Schema

  schema "employees" do
    field :name, :string
    field :age, :integer, default: 0
  end
end

# schema(source, list)
  # Define uma estrutura de esquema com um nome de origem e definições de campo.
# field(name, type \\ :string, opts \\ [])
  # Define um campo no esquema com nome e tipo fornecidos.

# O módulo Company.Employee diz ao Ecto que esse esquema se refere à tabela `employees`
# e que temos duas colunas :name que é uma string e :age que é um inteiro de padrão 0.

# vamos criar uma nova pessoa e olhar nosso esquema
$ iex -S mix

iex> %Company.Employee{}
# %Company.Employee{
#   __meta__: #Ecto.Schema.Metadata<:built, "employees">,
#   age: 0,
#   id: nil,
#   name: nil
# }

# como esperado, recebemos um novo Employee com o valor padrão 0 aplicado a age.

# vamos criar uma pessoa “real”:
iex> %Company.Employee{name: "Hercules", age: 24}
# %Company.Employee{
#   __meta__: #Ecto.Schema.Metadata<:built, "employees">,
#   age: 24,
#   id: nil,
#   name: "Hercules"
# }

# Ao definir um esquema, o Ecto define automaticamente uma estrutura com os campos do esquema
# podemos interagir com eles como qualquer outro map ou struct
iex> employee = %Company.Employee{name: "Hercules", age: 24}
iex> employee.name
# "Hercules"
iex> employee.age
# 24
iex> Map.get(employee, :name)
# "Hercules"
iex> %{name: name} = employee
# %Company.Employee{
#   __meta__: #Ecto.Schema.Metadata<:built, "employees">,
#   age: 24,
#   id: nil,
#   name: "Hercules"
# }
iex> name
# "Hercules"

# também podemos atualizar o esquema
iex> %{employee | age: 1124}
# %Company.Employee{
#   __meta__: #Ecto.Schema.Metadata<:built, "employees">,
#   age: 1124,
#   id: nil,
#   name: "Hercules"
# }

iex> Map.put(employee, :name, "Merlin")
# %Company.Employee{
#   __meta__: #Ecto.Schema.Metadata<:built, "employees">,
#   age: 24,
#   id: nil,
#   name: "Merlin"
# }
