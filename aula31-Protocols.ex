# Protocolo
# Referência e funções para trabalhar com protocolos.

# Um protocolo especifica uma API que deve ser definida por suas implementações.
# Um protocolo é definido com Kernel.defprotocol/2 e suas implementações com Kernel.defimpl/2.

# No Elixir podemos escrever código polimórfico, ou seja, código que funciona com diferentes formas/tipos,
# usando protocolos.

# Um protocolo pode ser implementado para cada estrutura de dados do protocolo.
# É possível implementar protocolos para todos os tipos de Elixir:
# Structs, Tuple, Atom, List, BitString, Integer, Float, Function, PID, Map, Port, Reference, Any.
# pela opção for: []
# A estrutura de dados para a qual você está implementando o protocolo deve ser o primeiro argumento
# para todas as funções definidas no protocolo.

# Elixir vem com uma série de protocolos integrados
# O protocolo String.Chars é responsável por converter uma estrutura em um binário (somente se aplicável).
# A única função que precisa ser implementada é to_string/1, que faz a conversão.

iex> to_string(5)
# "5"
iex> to_string(12.5)
# "12.5"
iex> to_string("foo/bar")
# "foo/bar"
iex> to_string({:tuple})
# ** (Protocol.UndefinedError) protocol String.Chars not implemented for {:tuple} of type Tuple
    # (elixir 1.11.3) lib/string/chars.ex:3: String.Chars.impl_for!/1
    # (elixir 1.11.3) lib/string/chars.ex:22: String.Chars.to_string/1

# Como você pode ver, obtemos um erro de protocolo porque não há nenhuma implementação para tuplas.

# Implementando um protocol
# Vimos que to_string/1 ainda não foi implementado para tuplas, então vamos adicioná-lo.
# Para criar uma implementação, usaremos defimpl/2 com nosso protocolo e forneceremos a opção :for e nosso tipo.

iex> defimpl String.Chars, for: Tuple do
  def to_string(tuple) do
    interior =
      tuple
      |> Tuple.to_list()
      |> Enum.map(&Kernel.to_string/1)
      |> Enum.join(", ")

    "{#{interior}}"
  end
end

# funções de captura, Capturar significa e pode transformar uma função em funções anônimas
# que podem ser passadas como argumentos para outra função ou ser vinculadas a uma variável.
# e pode capturar dois tipos de funções:
função nomeada e aridade vinda do módulo: &(nome_do_módulo.função_nome/aridade).
função local: defmodule Module do
                def func2 (data) do Enum.map (data, &func/1) end
                def func (var) end
              end


# agora seremos capazes de chamar to_string/1 em uma tupla sem obter um erro
iex> to_string({3.14, :py, "elixir", ["1_11_3"]})
# "{3.14, py, elixir, 1_11_3}"


# Criando um protocolo
# criamos um protocolo defprotocol/2, e implementar to_atom/1

defprotocol AsAtom do
  def to_atom(data)
end

defimpl AsAtom, for: Atom do
  def to_atom(atom), do: atom
end

defimpl AsAtom, for: BitString do
  defdelegate to_atom(string), to: String
end

defimpl AsAtom, for: List do
  defdelegate to_atom(list), to: List
end

defimpl AsAtom, for: Map do
  def to_atom(map), do: List.first(Map.keys(map))
end

# defdelegate (func, opts) Define uma função que delega para outro módulo.
# :to - o módulo para o qual enviar.
# :as - a função para chamar no destino fornecido em :to.
  # Este parâmetro é opcional e o padrão é o nome que está sendo delegado na função `func`

iex> import AsAtom
# AsAtom
iex> to_atom(:an_atom)
# :an_atom
iex> to_atom("string")
# :string
iex> to_atom([1, 2])
# :"\x01\x02"
iex> to_atom(%{foo: "bar"})
# :foo

# Vale a pena notar que, embora embaixo dos panos structs sejam Maps, mas eles não compartilham implementações
# de protocolo com Maps. Eles não são enumeráveis, não podem ser acessados.

# Como podemos ver, os protocolos são uma forma poderosa de obter polimorfismo.
