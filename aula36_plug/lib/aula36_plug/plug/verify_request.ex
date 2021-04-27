defmodule Aula36Plug.Plug.VerifyRequest do
  defmodule IncompleteRequestError do
    @moduledoc """
    Levanta um erro quando um campo obrigatório está faltando.
    """

    defexception message: "", plug_status: 400
  end

  def init(options) do
    options
  end

  def call(%Plug.Conn{request_path: path} = conn, opts) do
    if path in opts[:paths], do: verify_request!(conn.params, opts[:fields])
    conn
  end

  defp verify_request!(params, fields) do
    verified =
      params
      |> Map.keys()
      |> contains_fields?(fields)

    unless verified, do: raise(IncompleteRequestError)
  end

  defp contains_fields?(keys, fields), do: Enum.all?(fields, &(&1 in keys))
end
