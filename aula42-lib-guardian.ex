# Guardian é uma biblioteca de autenticação amplamente utilizada tendo como base o JWT (JSON Web Tokens).
# (https://github.com/ueberauth/guardian)

# Um JWT pode fornecer um token rico para autenticação.
# Onde muitos sistemas de autenticação fornecem acesso à apenas o identificador do sujeito para o recurso,
# JWTs fornecem isto junto com outras informações como:
#   Quem emitiu o token.
#   Para quem é o token.
#   Que sistema deve usar o token.
#   Quando ele foi emitido.
#   Quando o token expira.
# Além desses campos, o Guardian fornece alguns outros campos para facilitar a funcionalidade adicional:
#   Que tipo é o token.
#   Quais são as permissões do portador?
# Esses são apenas os campos básicos de um JWT.
# Você é livre para adicionar qualquer informação adicional necessária ao seu aplicativo.
# Apenas lembre-se de mantê-lo curto, pois o JWT deve caber no Header HTTP.

# Essa riqueza significa que você pode passar JWTs em seu sistema
# como uma unidade de credenciais totalmente contida.

# Os tokens JWT podem ser usados ​​para autenticar qualquer parte do seu aplicativo:
#   Single page applications.
#   Controllers (via browser session).
#   Controllers (via authorization headers - API).
#   Phoenix Channels.
#   Service to Service requests.
#   Inter-process.
#   Acesso de terceiros entre processos (OAuth).
#   Funcionalidade de lembrar de mim.
#   Outras interface - TCP puro, UDP, CLI, etc.
# Os tokens JWT podem ser usados ​​em qualquer lugar em seu aplicativo onde você precise fornecer autenticação verificável.

# Você não precisa de um banco de dados para salvar um JWT.
# Você pode simplesmente confiar nos carimbos de data/hora (timestamps) emitidos e de expiração para controlar o acesso.
# Frequentemente você acabará usando um banco de dados para procurar por seu registro de usuário
# mas o JWT em si não necessita disso.

# Por exemplo, se você fosse usar o JWT para autenticar a comunicação em um socket UDP,
# você provavelmente não usaria um banco de dados. Codifique todas as informações
# de que você precisa diretamente no token quando você emiti-lo.
# Uma vez que você verificá-lo (verificar se ele está assinado corretamente), você está pronto para continuar.

# No entanto, você pode usar um banco de dados para salvar o JWT.
# Se você fizer isso, você ganha a habilidade de verificar se o token ainda é válido, isto se ainda não foi revogado.
# Ou você pode usar os registros no banco de dados para forçar um logout de todos os tokens de um usuário.
# Isso é bem simples de fazer no Guardian usando o GuardianDb (https://github.com/ueberauth/guardian_db).
# GuardianDb usa Guardians ‘Hooks’ para realizar verificações de validação, salvar e excluir do banco de dados.

# instalar o Hex (se você já instalou o Hex, ele atualizará o Hex para a versão mais recente).
$ mix local.hex

# Atualiza o gerador do projeto Phoenix localmente (se você já instalou o Phoenix,).
$ mix local.phx

# instala o gerador do projeto Phoenix localmente na ultima versão.
$ mix archive.install hex phx_new

# vamos criar nosso aplicação
$ mix phx.new aula42_auth_me

# em mix.exs, adicione o guardian o pbkdf2_elixir era para criptografar a senha.
defp deps do
  [
    ...
    {:guardian, "~> 2.1"},
    {:pbkdf2_elixir, "~> 1.4"}
  ]
end

# em mix.exs, adicione o guardian.
def application do
  [
   ...
    extra_applications: [..., :guardian]
  ]
end

# Em seguida, precisamos adicionar nossa configuração em config/config.exs
config :aula42_auth_me, Aula42AuthMe.Guardian,
       issuer: "aula42_auth_me",
       secret_key: ""

# para gerar uma  Chave secreta.
$ mix guardian.gen.secret
# ou
$ mix phoenix.gen.secret

Parabéns! Temos uma implementação do Guardian funcionando.

Você não deve codificar a sua chave privada diretamente em sua configuração geral. Em vez disso, cada ambiente deve ter sua própria chave privada. É comum usar o ambiente do Mix para chaves em desenvolvimento e teste. Mas em staging e produção, você deve usar chaves fortes.
