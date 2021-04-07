# Changesets permitir a filtragem, modificação, a validação e a definição de restrições das estruturas.

# Para inserir, atualizar ou excluir as informações de um banco de dados,
# Ecto.Repo.insert/2, Ecto.Repo.update/2 e Ecto.Repo.delete/2 requerem um changeset como primeiro parâmetro.

# O Ecto fornece uma solução completa para trabalhar com alteração de dados na forma do módulo Changeset e de estruturas de dados.

# Criando primeiro changeset

# Vamos criar uma estrutura %Changeset{} vazia
iex > %Ecto.Changeset{}
# %Ecto.Changeset<action: nil, changes: %{}, errors: [], data: nil, valid?: false>

# Como você pode ver, tem alguns campos potencialmente úteis, mas estão todos vazios.
# Para um changeset ser verdadeiramente útil, quando o criamos, precisamos fornecer um diagrama de como são os dados.
# O melhor diagrama para nossos dados são os schemas que criamos que definem nossos campos e tipos.

# Para criar um changeset usando o schema Employee, vamos usar Ecto.Changeset.cast/4

iex > Ecto.Changeset.cast(%Company.Employee{name: "Bob"}, %{}, [:name, :age])
# #Ecto.Changeset<action: nil, changes: %{}, errors: [], data: #Company.Employee<>, valid?: true>

# O primeiro parâmetro é o dado original - uma struct %Company.Employee{}.
# O segundo parâmetro são as alterações que queremos fazer - um map vazio %{}.
# O terceiro parâmetro é uma lista de campos permitidos - []. o que nos dá a capacidade
#   de controlar quais campos podem ser alterados e proteger o resto.

iex> Ecto.Changeset.cast(%Company.Employee{name: "Bob"}, %{"name" => "Hercules"}, [:name, :age])
# #Ecto.Changeset<
#   action: nil,
#   changes: %{name: "Hercules"},
#   errors: [],
#   data: #Company.Employee<>,
#   valid?: true
# >

iex> Ecto.Changeset.cast(%Company.Employee{name: "Bob"}, %{"name" => "Hercules"}, [])
# #Ecto.Changeset<action: nil, changes: %{}, errors: [], data: #Company.Employee<>, valid?: true>
# Você pode ver o novo nome foi ignorado, onde não foi explicitamente permitido.

# Uma alternativa para o cast/4 é o change/2, que não tem a capacidade de filtrar alterações como cast/4.
# É útil quando você confia na origem que fez as alterações ou quando trabalha com dados manualmente.

# podemos criar changesets mas sem validação, quaisquer alterações ao nome do usuário serão aceitas
iex> Ecto.Changeset.change(%Company.Employee{name: "Bob"}, %{name: ""})
# #Ecto.Changeset<
#   action: nil,
#   changes: %{name: ""},
#   errors: [],
#   data: #Company.Employee<>,
#   valid?: true
# >

# Validações
# O Ecto vem com várias funções de validação integradas para nos ajudar.
# Vamos utilizar Ecto.Changeset em varias, então vamos importar Ecto.Changeset para o nosso módulo Company.Employee,
# que também contém o nosso schema.

# em lib\company\employee.ex
defmodule Company.Employee do
  use Ecto.Schema
  import Ecto.Changeset

  ...
end


# depois de importar podemos usar a função cast/3 diretamente.
# vamos criar um função construtora `changeset`. É comum ter uma ou mais funções de construção de changeset
# para um schema.

# Vamos fazer uma que aceite uma struct, um map de alterações e retorne um changeset:
def changeset(struct, params) do
  struct
  |> cast(params, [:name])
  |> validate_required([:name])
end

cast(data, params, permitted, opts \\ [])
  # Aplica os parâmetros fornecidos `params` como alterações para os dados fornecidos `data` de acordo
  # com o conjunto de chaves permitidas fornecido `permitted`. Retorna um changeset.

validate_required(changeset, fields, opts \\ [])
  # Valida se um ou mais campos estão presentes no changeset.

# Nota: não esqueça de executar ´recompile()` quando estiver trabalhando no iex, caso contrário,
# as alterações feitas no código não terão efeito se o projeto ainda esta executando como `iex -S mix`.

# Quando chamamos a função Company.Employee.changeset/2 e passamos um nome vazio,
# o changeset não será mais válido, e irá conter uma mensagem de erro.
iex> Company.Employee.changeset(%Company.Employee{}, %{name: ""})
# #Ecto.Changeset<
  # action: nil,
  # changes: %{},
  # errors: [name: {"can't be blank", [validation: :required]}],
  # data: #Company.Employee<>,
  # valid?: false
# >
iex> Company.Employee.changeset(%Company.Employee{}, %{"name" => ""})
# #Ecto.Changeset<
  # action: nil,
  # changes: %{},
  # errors: [name: {"can't be blank", [validation: :required]}],
  # data: #Company.Employee<>,
  # valid?: false
# >

# Caso você tente usar Repo.insert(changeset), irá receber um {:error, changeset} de volta com o mesmo erro,
# então você não precisa checar changeset.valid? você mesmo toda vez.
# É mais fácil tentar executar o insert, update ou delete, e então processar os erros depois, caso existam.
iex> changeset = Company.Employee.changeset(%Company.Employee{}, %{"name" => ""})
iex> Repo.insert(changeset)
# ** (UndefinedFunctionError) function Repo.insert/1 is undefined (module Repo is not available)
    # Repo.insert(#Ecto.Changeset<action: nil, changes: %{}, errors: [name: {"can't be blank", [validation: :required]}], data: #Company.Employee<>, valid?: false>)

# validar o tamanho da string
def changeset(struct, params) do
  struct
  |> cast(params, [:name, :age])
  |> validate_required([:name])
  |> validate_length(:name, min: 2)
end

validate_length(changeset, field, opts)
  # Valida uma mudança é uma string ou lista de comprimento fornecido.

iex> Company.Employee.changeset(%Company.Employee{}, %{"name" => "A"})
# #Ecto.Changeset<
#   action: nil,
#   changes: %{name: "A"},
#   errors: [
#     name: {"should be at least %{count} character(s)",
#       [count: 2, validation: :length, kind: :min, type: :string]}
#   ],
#   data: #Company.Employee<>,
#   valid?: false
# >

# existe varias outros validadores integrados: https://hexdocs.pm/ecto/Ecto.Changeset.html#summary

# Validações Customizadas
# Embora os validadores integrados cubram uma ampla gama de casos de uso,
# você ainda pode precisar de algo diferente.

# Toda função que começou com `validate_` que usamos até agora aceita e retorna um %Ecto.Changeset{},
# então basta criarmos o nosso começando com `validate_`

# podemos criar uma validação que aceita somente nomes de personagens fictícios
# em lib\company\employee.ex
@fictional_names ["Black Panther", "Wonder Woman", "Spiderman", "Flash"]
def validate_fictional_name(changeset) do
  name = get_field(changeset, :name)

  if name in @fictional_names do
    changeset
  else
    add_error(changeset, :name, "is not a superhero")
  end
end

# get_field(changeset, key, default \\ nil)
  # Obtém um campo das alterações ou dos dados.
# add_error(changeset, key, message, keys \\ [])
  # Adiciona um erro ao conjunto de alterações.

# e adicionamos em nossa função changeset
|> validate_fictional_name()

# É uma boa prática retornar sempre um %Ecto.Changeset{},
# então você pode usar o operador |> e facilitar a adição de mais validações posteriormente.

iex> Company.Employee.changeset(%Company.Employee{}, %{"name" => "Hercules"})
# #Ecto.Changeset<
#   action: nil,
#   changes: %{name: "Hercules"},
#   errors: [name: {"is not a superhero", []}],
#   data: #Company.Employee<>,
#   valid?: false
# >
iex> Company.Employee.changeset(%Company.Employee{}, %{"name" => "Flash"})
# #Ecto.Changeset<
#   action: nil,
#   changes: %{name: "Flash"},
#   errors: [],
#   data: #Company.Employee<>,
#   valid?: true
# >

# a função validate_inclusion/4 poderia ter sido usada;
# validate_inclusion(changeset, field, data, opts \\ [])
  # Valida uma alteração incluída no enumerável fornecido.Opções :message - a mensagem em caso de falha, o padrão é "is invalid"

# Adicionando alterações programaticamente
# Às vezes você quer introduzir mudanças em um changeset manualmente.
# O put_change/3 existe para este propósito.

# Em vez de tornar obrigatório o campo name, vamos permitir usuários se inscrevam sem um nome,
# e os chamaremos de “Anonymous”. A função deve aceitar e retorna um changeset, assim como o validate_fictional_name/1.
def set_name_if_anonymous(changeset) do
  name = get_field(changeset, :name)

  if is_nil(name) do
    put_change(changeset, :name, "Anonymous")
  else
    changeset
  end
end

# put_change(changeset, key, value)
  # Coloca uma alteração na chave fornecida com valor.

# Nós so podemos definir o nome do usuário como “Anonymous”, apenas quando se registrar na aplicação;
# criaremos uma nova função de changeset:
def registration_changeset(struct, params) do
  struct
  |> cast(params, [:name, :age])
  |> set_name_if_anonymous()
end

# Agora nós não temos que passar um name, e "Anonymous" será definido automaticamente, como esperado:
iex> Company.Employee.registration_changeset(%Company.Employee{}, %{"name" => ""})
# #Ecto.Changeset<
#   action: nil,
#   changes: %{name: "Anonymous"},
#   errors: [],
#   data: #Company.Employee<>,
#   valid?: true
# >
iex> Company.Employee.registration_changeset(%Company.Employee{}, %{})
# #Ecto.Changeset<
#   action: nil,
#   changes: %{name: "Anonymous"},
#   errors: [],
#   data: #Company.Employee<>,
#   valid?: true
# >

# Tendo uma função changeset que tem uma responsabilidade específica (como registration_changeset/2)
# não é incomum — às vezes, você precisa da flexibilidade para executar apenas algumas validações ou filtrar parâmetros específicos.

# salvando no banco se passando pelas validações
# em lib\company\employee.ex
def set_employee(struct, params) do
  struct
  |> registration_changeset(params)
  |> validate_fictional_name()
  |> Company.Repo.insert!()
end

iex> Company.Employee.set_employee(%Company.Employee{}, %{})
# ** (Ecto.InvalidChangesetError) could not perform insert because changeset is invalid.
# Errors
    # %{name: [{"is not a superhero", []}]}
# Applied changes
    # %{name: "Anonymous"}
# Params
    # %{}
# Changeset
    # #Ecto.Changeset<
      # action: :insert,
      # changes: %{name: "Anonymous"},
      # errors: [name: {"is not a superhero", []}],
      # data: #Company.Employee<>,
      # valid?: false
    # >

iex> Company.Employee.set_employee(%Company.Employee{}, %{name: "Flash"})
# %Company.Employee{
#   __meta__: #Ecto.Schema.Metadata<:loaded, "employees">,
#   age: 0,
#   id: 1,
#   name: "Flash"
# }
# hh:mm:ss.ms [debug] QUERY OK db=94.0ms decode=31.0ms queue=140.9ms idle=218.9ms
# INSERT INTO "employees" ("age","name") VALUES ($1,$2) RETURNING "id" [0, "Flash"]

# usando um software para ver o banco la vai estar
id | name  | age
1  | Flash | 0

# Há muitos casos de uso e funcionalidades, tal como changesets sem schema(https://hexdocs.pm/ecto/Ecto.Changeset.html#module-schemaless-changesets)
# que você pode usar para validar qualquer dado, ou lidar com efeitos colaterais ao lado do changeset (prepare_changes/2)
# ou trabalhar com associações e incorporações.
