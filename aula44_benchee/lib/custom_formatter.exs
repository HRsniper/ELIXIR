defmodule CustomFormatter do
  def output(suite) do
    suite
    |> format()
    |> IO.write()

    suite
  end

  defp format(suite) do
    Enum.map_join(suite.scenarios, "\n", fn scenario ->
      "Media para #{scenario.job_name}: #{scenario.run_time_data.statistics.average}"
    end)
  end
end

list = Enum.to_list(1..10_000)
map_fun = fn i -> [i, i * i] end

Benchee.run(
  %{
    "flat_map" => fn -> Enum.flat_map(list, map_fun) end,
    "map.flatten" => fn -> list |> Enum.map(map_fun) |> List.flatten() end
  },
  formatters: [&CustomFormatter.output/1]
)
