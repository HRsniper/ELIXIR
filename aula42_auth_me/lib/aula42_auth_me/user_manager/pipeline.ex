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
