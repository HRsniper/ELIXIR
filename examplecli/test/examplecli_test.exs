defmodule ExamplecliTest do
  use ExUnit.Case
  doctest Examplecli

  test "greets the world" do
    assert Examplecli.hello() == :world
  end
end
