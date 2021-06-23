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
