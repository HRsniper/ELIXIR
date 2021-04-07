defmodule CompanyTest do
  use ExUnit.Case
  doctest Company

  test "greets the world" do
    assert Company.hello() == :world
  end
end
