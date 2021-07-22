ExUnit.start()

# definição de mocks dinâmicos
Mox.defmock(HTTPoison.BaseMock, for: HTTPoison.Base)

# Substitua as configurações de 'config' (semelhante a adicioná-las a 'config/test.exs').
Application.put_env(:aula48_mox, :http_client, HTTPoison.BaseMock)
