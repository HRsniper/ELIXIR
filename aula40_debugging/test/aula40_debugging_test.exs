defmodule Aula40DebuggingTest do
  use ExUnit.Case
  doctest Aula40Debugging

  test "greets the world" do
    assert Aula40Debugging.hello() == :world
  end
end
