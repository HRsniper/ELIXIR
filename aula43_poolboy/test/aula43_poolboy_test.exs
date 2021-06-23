defmodule Aula43PoolboyTest do
  use ExUnit.Case
  doctest Aula43Poolboy

  test "greets the world" do
    assert Aula43Poolboy.hello() == :world
  end
end
