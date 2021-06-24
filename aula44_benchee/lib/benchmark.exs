map_fun = fn i -> [i, i * i] end

inputs = %{
  "small list" => Enum.to_list(1..100),
  "medium list" => Enum.to_list(1..10_000),
  "large list" => Enum.to_list(1..1_000_000)
}

Benchee.run(
  %{
    "flat_map" => fn list -> Enum.flat_map(list, map_fun) end,
    "map.flatten" => fn list -> list |> Enum.map(map_fun) |> List.flatten() end
  },
  inputs: inputs,
  formatters: [
    Benchee.Formatters.Console,
    Benchee.Formatters.HTML,
    {Benchee.Formatters.CSV, file: "benchmark_output.csv"},
    {Benchee.Formatters.JSON, file: "benchmark_output.json"}
  ],
  print: [fast_warning: false],
  memory_time: 1
)
