# Os módulos permitem a organização de funções em um namespace. Além de agrupar funções,
  # eles permitem definir funções nomeadas e privadas que cobrimos na lição sobre funções.

defmodule Example do
  def greeting(name) do
    "Hello #{name}."
  end
end

iex> Example.greeting("Sean")
# "Hello Sean."

# É possível aninhar módulos em Elixir, permitindo-lhe promover um namespace para a sua funcionalidade:
defmodule Example.Greetings do # ou
defmodule Example do
  defmodule Greetings do

    def morning(name) do
      "Good morning #{name}."
    end

    def evening(name) do
      "Good night #{name}."
    end
end

iex> Example.Greetings.morning "Sean"
# "Good morning Sean."
iex>  Example.Greetings.evening "Sean"
# "Good night Sean."

# Atributos de módulo são mais comumente usados como constantes no Elixir.
defmodule Example do
  @greeting "Hello"

  def greeting(name) do
    ~s(#{@greeting} #{name}.)
  end
end
iex> Example.greeting("HR")
# "Hello HR."

# É importante notar que existem atributos reservados no Elixir. Os três mais comuns são:
# moduledoc — Documenta o módulo atual.
# doc — Documentação para funções e macros.
# behaviour — Usa um OTP ou comportamento definido.


# Structs são mapas especiais com um conjunto definido de chaves e valores padrões.
#  Ele deve ser definido dentro de um módulo, no qual leva o nome dele.
#  É comum para um struct ser a única coisa definido dentro de um módulo.

defmodule Users do
  defmodule Login do
    defstruct name: "HR", roles: []
  end
end

iex> %Users.Login{}
# %Users.Login{name: "HR", roles: []}
iex> %Users.Login{name: "HRsniper"}
# %Users.Login{name: "HRsniper", roles: []}
iex> %Users.Login{name: "Valin", roles: [:creator]}
# %Users.Login{name: "Valin", roles: [:creator]}

iex> hr = %Users.Login{}
iex> hercules = %Users.Login{hr | name: "Hercules"}

# você pode associar estruturas contra mapas:
iex> %{name: "Hercules"} = hercules
# %Users.Login{name: "Hercules", roles: []}

# structs incluem introspecção customizáveis.
iex> inspect(hercules)
# "%Users.Login{name: \"Hercules\", roles: []}"

# a funcionalidade @derive protege um campo para incluir/excluir do resultado
defmodule Users.Login do
  @derive {Inspect, only: [:name]}
  defstruct name: nil, roles: []
end
# Nota: podemos também usar @derive {Inspect, except: [:roles]}, que é equivalente.
iex> %Users.Login{name: "HR :)"}
# Users.Login<name: "HR :)", ...>

# alias Permite-nos criar pseudônimos, usado frequentemente em código Elixir:
defmodule Sayings.Greetings do
  def basic(name), do: "Hi, #{name}"
end

defmodule Hello do
  alias Sayings.Greetings

  def greeting(name), do: Greetings.basic(name)

end
iex> Hello.greeting("Schob")
# "Hi, Schob"

# Sem alias
#
defmodule Hello do
  def greeting(name), do: Sayings.Greetings.basic(name)
end
#

# Se houver um conflito com dois aliases ou você deseja criar um pseudônimo
#  para um nome completamente diferente, podemos usar a opção :as:
defmodule Example do
  alias Sayings.Greetings, as: Hi

  def print_message(name), do: Hi.basic(name)
end
iex> Example.print_message("Schob")
# "Hi, Schob"

# É possível criar pseudônimos para múltiplos módulos de uma só vez:
defmodule Sayings
  defmodule Sayings.Greetings do
    def basic(name), do: "Hi, #{name}"
  end

  defmodule Sayings.Farewells do
    def basic(name), do: "pleasure #{name}, see you later"
  end
end

defmodule Example do
  alias Sayings.{Greetings, Farewells}

  def print_greeting(name), do: Greetings.basic(name)
  def print_farewell(name), do: Farewells.basic(name)
end

iex> Example.print_greeting("Hercules")
# "Hi, Hercules"
iex> Example.print_farewell("Hercules")
# pleasure Hercules, see you later


# Se queremos importar funções em vez de criar pseudônimos de um módulo, podemos usar import:
iex> last([1, 2, 3])
# ** (CompileError) iex: undefined function last/1
iex> import List
# List
iex> last([1, 2, 3])
# 3

# Por padrão todas as funções e macros são importadas, porém nós podemos filtrá-los usando as
#  opções :only e :except. Para importar funções e macros específicos nós temos que fornecer
#  os pares de nome para :only e :except. ( nome/aridade )
# para escolher mais de um coloca se , [flatten: 1, keyfind: 4]

iex> import List, only: [last: 1]
# List
iex> first([1, 2, 3])
# ** (CompileError) iex: undefined function first/1
iex> last([1, 2, 3])
# 3

iex> import List, except: [delete: 2]
iex> delete([1, 2, 3], 2)
# ** (CompileError) iex: undefined function delete/2
iex> delete_at([1, 2, 3], 0)
# [2, 3]

# Além do par nome/aridade existem dois átomos especiais, :functions e :macros,
#   que importam apenas funções e macros
import List, only: :functions
import List, only: :macros

# Por padrão, as funções que começam com _ não são importadas.
  # Se você realmente deseja importar uma função começando com,
  # _ deve incluí-la explicitamente no seletor :only
import File.Stream, only: [__build__: 3]

# É importante notar que import/2 é lexical.


# Nós podemos usar require para dizer ao Elixir que vamos usar macros de outro módulo.
#  A pequena diferença com import é que ele permite usar macros, mas não funções do módulo especificado.
# require/2 também aceita :as como opção, por isso configura automaticamente um alias.
defmodule Math do
  defmacro ifm(expr, opts) do
      quote do
        if unquote(expr), unquote(opts)
      end
    end
end

iex> require Math
# Math

Math.ifm true do
  IO.puts("It works")
end

iex> It works
...> :ok

# Com a macro use podemos dar habilidade a outro módulo para modificar a sua definição/contexto atual.
# Quando invocamos use em nosso código estamos invocando o callback __using__/1 definido pelo módulo declarado.
# O resultado da macro __using__/1 passa a fazer parte da definição do módulo

defmodule Hello do
  defmacro __using__(_opts) do
    quote do
      def hello(name), do: "Hi, #{name}"
    end
  end
end
iex> Hello.__using__("a")
# ** (CompileError) iex: you must require Hello before invoking the macro Hello.__using__/1

defmodule Example do
  use Hello
end

# use Hello, veremos que hello/1 está disponível no módulo Example.
iex> Example.hello("Sean")
# "Hi, Sean"

# podemos ver que use invoca o callback __using__/1 dentro do Hello o qual acaba adicionando
#  o código dentro do módulo Example.


#  __using__/1 suporta opções. Vamos adicionar a opção greeting:
defmodule Hello do
  defmacro __using__(opts) do
    greeting = Keyword.get(opts, :greeting, "Hi")

    quote do
      def hello(name), do: unquote(greeting) <> ", #{name}"
    end
  end
end

# Vamos atualizar nosso módulo Example para incluir a opção nova greeting:
defmodule Example do
  use Hello, greeting: "Hola"
end

iex> Example.hello("Sean")
# "Hola, Sean"
