defmodule Aula36PlugTest do
  use ExUnit.Case
  doctest Aula36Plug

  test "greets the world" do
    assert Aula36Plug.hello() == :world
  end
end
