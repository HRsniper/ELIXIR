defmodule Aula48Mox.MyMox do
  def get_lesson_name(name) do
    http_client().get("https://elixirschool.com/pt/lessons/basics/#{name}")
  end

  defp http_client do
    Application.get_env(:aula48_mox, :http_client)
  end
end
