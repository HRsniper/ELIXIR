defmodule Aula45Bypass.SchedulerTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Aula45Bypass.Scheduler

  defmodule TestCheck do
    def ping(_sites), do: [{:ok, "HTTP Status 200"}, {:error, "HTTP Status 404"}]
  end

  test "health checks are run and results logged" do
    opts = [health_check: TestCheck, interval: 1, sites: ["http://example.com", "http://example.org"]]

    output =
      capture_log(fn ->
        {:ok, _pid} = GenServer.start_link(Scheduler, opts)
        :timer.sleep(10)
      end)

    assert output =~ "HTTP Status 200"
    # assert output =~ "[info]  HTTP Status 200"

    assert output =~ "HTTP Status 404"
    # assert output =~ "[error] HTTP Status 404"
  end
end
