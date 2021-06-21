defmodule TestMod do
  def sum([a, b]) do
    b = 0

    require IEx; IEx.pry

    a + b
  end
end

IO.puts(TestMod.sum([34, 65]))
