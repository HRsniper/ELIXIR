defmodule Aula44BencheeTest do
  use ExUnit.Case
  doctest Aula44Benchee

  test "greets the world" do
    assert Aula44Benchee.hello() == :world
  end
end
