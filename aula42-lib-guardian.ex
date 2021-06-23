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
config :aula42_auth_me, Aula42AuthMe.UserManager.Guardian,
       issuer: "aula42_auth_me",
       secret_key: ""

# para gerar uma  Chave secreta.
$ mix guardian.gen.secret
# ou
$ mix phoenix.gen.secret

# pegamos esse secret e colocamos em secret_key
...
secret_key: "EpdFNi/osIdlE+2ddvIN6jXpVV76ZmiuPzDweojvXUM+FU7cma71GaLiIgh6h4PT"

# Você não deve codificar a sua chave privada diretamente em sua configuração geral.
# Em vez disso, cada ambiente deve ter sua própria chave privada.
# É comum usar o ambiente do Mix para chaves em desenvolvimento e teste.
# Mas em staging e produção, você deve usar chaves fortes.

# Vamos criar um gerenciador de usuários Precisamos de algo para autenticar.
$ mix phx.gen.context UserManager User users username:string password:string

# verifique se o postgres esta rodando e crie o banco de dados
$ mix ecto.create
# Lembre-se de atualizar seu repositório executando migrações.
$ mix ecto.migrate

# vamos criar o módulo de implementação
# O Guardian precisa de uma implementação. Este módulo de implementação encapsula:
#   Tipo de token, configuração, codificação/decodificação, retornos de chamada.
# Você pode ter quantos módulos de implementação forem necessários, dependendo do seu aplicativo.
# Para este, porém, temos apenas um sistema de usuário simples, então precisaremos apenas de um.

# em lib\aula42_auth_me\user_manager\guardian.ex
defmodule Aula42AuthMe.UserManager.Guardian do
  use Guardian, otp_app: :aula42_auth_me

  alias Aula42AuthMe.UserManager

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    user = UserManager.get_user!(id)
    {:ok, user}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end

# 'subject_for_token' é usado para codificar o usuário no token e
# 'resource_from_claims' é usado para reidratar o usuário a partir das reivindicações.
# Existem muitos outros 'callbacks' (https://hexdocs.pm/guardian/Guardian.html#callbacks) que você pode usar.

# Hash de senha
# Isso também não é estritamente necessário para o Guardian.
# Implementaremos uma versão simples de hash de senha.
# Isso depende de sua aplicação e só é mostrado aqui para fins de estudo.

# Adicionamos :pbkdf2_elixir ao nosso mix deps no início. Vamos usá-los em dois lugares:
  # Ao definir a senha do usuário.
  # Ao verificar as credenciais de login.

# em lib\aula42_auth_me\user_manager\user.ex
...
alias Ecto.Changeset

def changeset(user, attrs) do
  ...
  |> put_password_hash()
end

defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
  change(changeset, password: Pbkdf2.hash_pwd_salt(password))
end

defp put_password_hash(changeset), do: changeset
...

# Agora precisamos verificar as credenciais do nome de usuário/senha.
# em lib\aula42_auth_me\user_manager.ex
...
import Ecto.Query, only: [from: 2]
...
...
def authenticate_user(username, plain_text_password) do
  query = from user in User, where: user.username == ^username

  case Repo.one(query) do
    nil ->
      Pbkdf2.no_user_verify()
      {:error, :invalid_credentials}

    user ->
      if Pbkdf2.verify_pass(plain_text_password, user.password) do
        {:ok, user}
      else
        {:error, :invalid_credentials}
      end
  end
end
...

# Neste ponto, os testes gerados automaticamente quando criamos o UserManager e o Usuário
# falhariam ao executar o teste de mistura. Isso se deve ao fato de que os testes gerados automaticamente
# não sabem sobre senhas, tudo o que sabe é que sua tabela Usuários tem duas colunas de string
# que precisam ser verificadas.
# Consertar os testes quebrados é simples queremos comparar as senhas criptografadas
# em vez das de texto simples.

# em test\aula42_auth_me\user_manager_test.exs
...
test "create_user/1 with valid data creates a user" do
  assert {:ok, %User{} = user} = UserManager.create_user(@valid_attrs)
  assert {:ok, user} == Pbkdf2.check_pass(user, "some password", hash_key: :password)
  assert user.username == "some username"
end
...
test "update_user/2 with valid data updates the user" do
  user = user_fixture()
  assert {:ok, %User{} = user} = UserManager.update_user(user, @update_attrs)
  assert {:ok, user} == Pbkdf2.check_pass(user, "some updated password", hash_key: :password)
  assert user.username == "some updated username"
end
...

# A próxima etapa é colocá-lo em seu aplicativo via HTTP.
# O Guardian fornece vários plugs para facilitar a integração em solicitações HTTP.
# O Guardian não requer o Phoenix, mas usar o Phoenix é mais fácil de demonstrar.
# A maneira mais fácil de integrar ao HTTP é por meio do roteador.
# Como as integrações HTTP do Guardian são todas baseadas em plugues,
# você pode usá-los em qualquer lugar em que um plugue possa ser usado.

# O fluxo geral do plug Guardian é:
#   Encontre um token na solicitação em algum lugar e verifique-o: plug Verify*.
#   Opcionalmente, carregue o recurso identificado no token: plug LoadResource.
#   Assegure-se de que haja um token válido para a solicitação e recuse o acesso se não houver: plug EnsureAuthenticated.

# Queremos que nosso pipeline cuide da 'sessão' e da 'header authentication' (onde procurar o token),
# carregue o usuário, mas não o aplicá-lo. Ao não aplicá-lo, podemos ter um "login" ou "talvez conectado".
# Podemos usar o plug 'Guardian.Plug.EnsureAuthenticated' para os casos em que devemos
# ter um usuário conectado usando pipelines Phoenix no roteador.

# Vamos criar nosso pipeline do UserManager.
# lib/aula42_auth_me/user_manager/pipeline.ex
defmodule Aula42AuthMe.UserManager.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :aula42_auth_me,
    error_handler: Aula42AuthMe.UserManager.ErrorHandler,
    module: Aula42AuthMe.UserManager.Guardian

  # Se houver um token de sessão, restrinja-o a um token de acesso e valide-o.
  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}

  # Se houver um  authorization header, restrinja-o a um token de acesso e valide-o.
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}

  # Carregue o usuário se alguma das verificações funcionou.
  plug Guardian.Plug.LoadResource, allow_blank: true
end

# Também precisaremos do manipulador de erros referenciado no nosso pipeline em :error_handler
# para lidar com o caso em que houve uma falha na autenticação.
# em lib/aula42_auth_me/user_manager/error_handler.ex
defmodule Aula42AuthMe.UserManager.ErrorHandler do
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    body = to_string(type)
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(401, body)
  end
end

# Este pipeline está pronto para uso. Agora precisamos fazer o login/logout do usuário e algum recurso para proteger.
# Para isso, vamos criar um controlador de sessões e usar o PageController para o nosso recurso protegido.

# em lib/aula42_auth_me_web/controllers/session_controller.ex
defmodule Aula42AuthMeWeb.SessionController do
  use Aula42AuthMeWeb, :controller

  alias Aula42AuthMe.{UserManager, UserManager.User, UserManager.Guardian}

  def new(conn, _) do
    changeset = UserManager.change_user(%User{})
    maybe_user = Guardian.Plug.current_resource(conn)

    if maybe_user do
      redirect(conn, to: "/protected")
    else
      render(conn, "new.html", changeset: changeset, action: Routes.session_path(conn, :login))
    end
  end

  def login(conn, %{"user" => %{"username" => username, "password" => password}}) do
    UserManager.authenticate_user(username, password)
    |> login_reply(conn)
  end

  def logout(conn, _) do
    conn
    # O nome completo deste módulo é Auth.UserManager.Guardian.Plug,
    # e os argumentos especificados no Guardian.Plug.sign_out()
    |> Guardian.Plug.sign_out()
    |> redirect(to: "/login")
  end

  defp login_reply({:ok, user}, conn) do
    conn
    |> put_flash(:info, "Welcome back!")
    # os argumentos especificados no Guardian.Plug.sign_in()
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: "/protected")
  end

  defp login_reply({:error, reason}, conn) do
    conn
    |> put_flash(:error, to_string(reason))
    |> new(%{})
  end
end

# vamos criar uma session view
# em lib/aula42_auth_me_web/views/session_view.ex
defmodule Aula42AuthMeWeb.SessionView do
  use Aula42AuthMeWeb, :view
end

# E agora vamos criar o modelo de login e o modelo secreto.
# em lib/auth_ex_web/templates/session/new.html.eex
<h2>Login Page</h2>

<%= form_for @changeset, @action, fn f -> %>

  <div class="form-group">
    <%= label f, :username, class: "control-label" %>
    <%= text_input f, :username, class: "form-control" %>
    <%= error_tag f, :username %>
  </div>

  <div class="form-group">
    <%= label f, :password, class: "control-label" %>
    <%= password_input f, :password, class: "form-control" %>
    <%= error_tag f, :password %>
  </div>

  <div class="form-group">
    <%= submit "Submit", class: "btn btn-primary" %>
  </div>
<% end %>

# Vamos fazer a implementação do recurso protegido no PageController.
...
def protected(conn, _) do
  user = Guardian.Plug.current_resource(conn)
  render(conn, "protected.html", current_user: user)
end
...

# Usando a função Guardian.Plug.current_resource(conn) aqui para buscar o usuário.
# Você deve carregá-lo primeiro usando o plug Guardian.Plug.LoadResource
# que incluímos em nosso pipeline de autenticação anteriormente.

# vamos criar o modelo secreto.
# em lib/auth_ex_web/templates/page/protected.html.eex
<h2>Protected Page</h2>
<p>You can only see this page if you are logged in</p>
<p>You re logged in as <%= @current_user.username %></p>

# O 'controller' e as 'views' não são estritamente parte do Guardian, mas precisamos de alguma forma
# de interagir com ele. A partir daqui, a única coisa que nos resta fazer é conectar-lo em nosso roteador phoenix.

# Nosso pipeline implementa 'maybe authenticated'.
# Usaremos o ':ensure_auth' abaixo para quando precisarmos ter certeza de que alguém está conectado.
pipeline :auth do
  plug Aula42AuthMe.UserManager.Pipeline
end

# Usamos ':ensure_auth' para falhar se não houver ninguém conectado.
pipeline :ensure_auth do
  plug Guardian.Plug.EnsureAuthenticated
end

# rota de talvez logado em espoco
scope "/", Aula42AuthMeWeb do
  pipe_through [:browser, :auth]

  get "/", PageController, :index

  get "/login", SessionController, :new
  post "/login", SessionController, :login
  get "/logout", SessionController, :logout
end

# Definitivamente logo em escopo
scope "/", Aula42AuthMeWeb do
  pipe_through [:browser, :auth, :ensure_auth]

  get "/protected", PageController, :protected
end

# vamos iniciar em modo interativo
$ iex -S mix

# criamos um usuário
iex> Aula42AuthMe.UserManager.create_user(%{username: "me", password: "my_pass"})
# INSERT INTO "users" ("password","username","inserted_at","updated_at") VALUES ($1,$2,$3,$4) RETURNING "id" ["$pbkdf2-sha512$160000$WaEeaRkBg2KQdrwHUgXi8A$YKXI6gLSdW8yiTq.290bWw.Ig5dg/ZQ3QwX.TDmg/0/AE80/zOgppBM3rq.dSUpY0XXOycLnLCB4UqhGBQtXXQ", "me", ~N[2021-06-23 00:55:38], ~N[2021-06-23 00:55:38]]
# {:ok,
#  %Aula42AuthMe.UserManager.User{
  #  __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
  #  id: 1,
  #  inserted_at: ~N[2021-06-23 00:55:38],
  #  password: "$pbkdf2-sha512$160000$WaEeaRkBg2KQdrwHUgXi8A$YKXI6gLSdW8yiTq.290bWw.Ig5dg/ZQ3QwX.TDmg/0/AE80/zOgppBM3rq.dSUpY0XXOycLnLCB4UqhGBQtXXQ",
  #  updated_at: ~N[2021-06-23 00:55:38],
  #  username: "me"
#  }}

# Agora saiamos do iex

# do jeito que criamos o projeto precisa-se instalar o node.js para rodar o webpack,
# dentro do diretório "assets" do projeto.
$ npm install
# ou
$ yarn

# iniciamos o servidor
$ mix phx.server

# Digite 'localhost:4000/protected' na barra de endereço do seu navegador e você verá "unauthenticated".
# Agora, digite 'localhost:4000/login' na barra de endereços do seu navegador
# e faça o login com seu nome de usuário e senha cadastrado anteriormente no iex.
# Você deve ser redirecionado automaticamente para a página protegida,
# Para fazer logout, digite 'localhost:4000/logout' na barra de endereços do seu navegador
# e você será redirecionado para a página de login.
# Em vez de fazer login, digite 'localhost:4000/protected' na barra de endereços do seu navegador
# e você verá "unauthenticated" novamente!
