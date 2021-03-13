# Às vezes você deseja que módulos compartilhem uma API pública, a solução para isso no Elixir
# são os comportamentos. Comportamentos desempenham dois papéis primários:
  # Definem um conjunto de funções que devem ser implementadas
  # Verificam se o conjunto foi realmente implementado

# Para entender melhor comportamentos, vamos implementar um para um módulo worker.
# Estes workers deverão implementar duas funções: init/1 e perform/2.

# @callback - define uma função necessária
# @macrocallback - define um macro necessária

defmodule Example.Worker do
  @callback init(state :: term) :: {:ok, new_state :: term} | {:error, reason :: term}

  @callback perform(args :: term, state :: term) ::
              {:ok, result :: term, new_state :: term}
              | {:error, reason :: term, new_state :: term}
end

# definimos init/1 como aceitando qualquer valor e retornando uma tupla de {:ok, state} ou {:error, reason}
# definomos perform/2 receberá alguns argumentos juntamente com o estado que inicializamos,
# esperamos retornar uma tupla de {:ok, result, state} ou {:error, reason, state}
# de forma muita semelhante aos GenServers.


# Implementando comportamentos
# Para especificar que um módulo implementa um determinado comportamento, o atributo @behaviour deve ser usado:

# Os comportamentos (Behaviours) em Elixir (e Erlang) são uma forma de separar e abstrair
# a parte genérica de um componente (que se torna o módulo de comportamento)
# da parte específica (que se torna o módulo de retorno de chamada).

# @optional_callbacks - define uma função optional

# vamos criar uma tarefa do módulo, que irá baixar um arquivo remoto e salvá-lo localmente:
defmodule Example.Downloader do
  @behaviour Example.Worker

  def init(opts), do: {:ok, opts}

  def perform(url, opts) do
    url
    |> HTTPoison.get!()
    |> Map.fetch(:body)
    |> write_file(opts[:path])
    |> respond(opts)
  end

  defp write_file(:error, _), do: {:error, :missing_body}

  defp write_file({:ok, contents}, path) do
    path
    |> Path.expand()
    |> File.write(contents)
  end

  defp respond(:ok, opts), do: {:ok, opts[:path], opts}
  defp respond({:error, reason}, opts), do: {:error, reason, opts}
end

# que tal um worker que comprime um array de arquivos?

defmodule Example.Compressor do
  @behaviour Example.Worker

  def init(opts), do: {:ok, opts}

  def perform(payload, opts) do
    payload
    |> compress
    |> respond(opts)
  end

  defp compress({name, files}), do: :zip.create(name, files)

  defp respond({:ok, path}, opts), do: {:ok, path, opts}
  defp respond({:error, reason}, opts), do: {:error, reason, opts}
end

# Enquanto o trabalho realizado é diferente, a API pública não é, e qualquer código usando esses
# módulos pode interagir com elas sabendo que responderão conforme esperado. Isso nos dá a capacidade
# de criarmos uma série de workers, todos realizando tarefas diferentes, mas de acordo com a mesma API pública.

# Se acontecer de adicionarmos um comportamento, mas não implementarmos todas as funções necessárias,
# um warning em tempo de compilação será gerado.

# removendo a função init/1 do nosso modulo Example.Compressor
warning: function init/1 required by behaviour Example.Worker is not implemented (in module Example.Compressor)
  iex: Example.Compressor (module)
