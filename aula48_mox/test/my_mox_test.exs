defmodule Aula48Mox.MyMoxTest do
  use ExUnit.Case, async: true
  alias Aula48Mox.MyMox

  import Mox
  # Certifica-se de que as simulações sejam verificadas quando o teste terminar.
  setup :verify_on_exit!

  test ":ok on 200" do
    expect(HTTPoison.BaseMock, :get, fn _ -> {:ok, "What a guy!"} end)

    assert {:ok, _} = MyMox.get_lesson_name("twinkie")
  end

  test ":error on 404" do
    expect(HTTPoison.BaseMock, :get, fn _ -> {:error, "Sorry!"} end)

    assert {:error, _} = MyMox.get_lesson_name("does-not-exist")
  end
end
