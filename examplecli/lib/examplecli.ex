defmodule Examplecli do
  @moduledoc """
  Documentation for `Examplecli`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Examplecli.hello()
      :world

  """
  def hello do
    :world
  end
end

defmodule Examplecli.CLI do
  def main(args \\ []) do
    args
    |> parse_args
    |> response
    |> IO.puts()
  end

  defp parse_args(args) do
    switches = [upcase: :boolean]

    {opts, word, _} =
      args
      |> OptionParser.parse(switches: switches)

    {opts, List.to_string(word)}
  end

  defp response({opts, word}) do
    if opts[:upcase], do: String.upcase(word), else: word
  end
end
