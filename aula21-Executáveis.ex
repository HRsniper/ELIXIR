# Para criar executáveis no Elixir utilizaremos escript.
# Escript produz um executável que pode rodar em qualquer sistema que tenha Erlang instalado.

# criamos um novo projeto
cli> mix new example_cli

# precisamos atualizar o Mixfile (mix.exs) para incluir a opção :escript em project
# e especificar no projeto o :main_module
# o módulo :main_module  deve ser chamado assim que o escript for iniciado.
# O módulo deve conter uma função nomeada main/1 que receberá os argumentos da linha de comando.

# dentro do mixfile (mix.exs) adicionamos
defmodule ExampleCli.MixProject do
  def project do
    [
      ...Outras Configs...
      escript: escript()
    ]
  end

  defp escript do
    [main_module: ExampleApp.CLI]
  end
end

# https://hexdocs.pm/mix/Mix.Tasks.Escript.Build.html#content

# Fazendo Parsing dos Argumentos
# podemos parsear os argumentos da linha de comando.
# Para fazer isso podemos utilizar a função OptionParser.parse/2 do Elixir e a opção :switches
# para indicar que nossa flag é booleana.

# OptionParser - Funções para analisar argumentos de linha de comando.

# OptionParser.parse/2 Analisa argv em uma lista de palavras-chave.
# retorna {parsed, args, invalid}

# :switches- define interruptores e seus tipos. Esta função ainda tenta analisar as opções que não estão nesta lista.
# switches: [{switch_name:, value}]

# :boolean - define o valor como verdadeiro quando fornecido

# dentro lib\examplecli.ex adicionamos
defmodule ExampleApp.CLI do
  defp parse_args(args) do
    {opts, word, _} = args |> OptionParser.parse(switches: [upcase: :boolean])

    {opts, List.to_string(word)}
  end

  defp response({opts, word}) do
    if opts[:upcase], do: String.upcase(word), else: word
  end

  def main(args \\ []) do
      args
      |> parse_args
      |> response
      |> IO.puts()
  end
end

# para criar um executável
cli> mix escript.build

# executando
cli>  ./examplecli --upcase Elixir
# ELIXIR

cli>  ./examplecli Elixir
# Elixir
