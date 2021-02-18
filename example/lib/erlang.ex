defmodule ErlangExample do
  def timed(fun, args) do
    {time, result} = :timer.tc(fun, args)
    IO.puts("Time: #{time} microseconds")
    IO.puts("Result: #{result}")
  end

  def createImg() do
    # width = 30
    # height = 30
    colorMode = :indexed
    bits = 8
    palette = {colorMode, bits, [{255, 0, 0}, {0, 0, 128}]}
    {_ok, file} = File.open("my.png", [:write])
    # config = %{:size => {width, height},
    #        :mode => {colorMode, bits},
    #        :palette => palette,
    #        :file => file}
    # png = :png.create(config)
    png = :png.create(%{:size => {30, 30}, :mode => {:indexed, 8}, :file => file, :palette => palette})
    IO.puts("Img: #{png}")
  end
end
