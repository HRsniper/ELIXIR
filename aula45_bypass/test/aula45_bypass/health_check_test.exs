defmodule Aula45Bypass.HealthCheckTest do
  use ExUnit.Case

  alias Aula45Bypass.HealthCheck

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "request with HTTP 200 response", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      assert "GET" == conn.method
      assert "/ping" == conn.request_path
      Plug.Conn.resp(conn, 200, "Bypass Response 200")
    end)

    assert {:ok, "Bypass Response 200"} = HealthCheck.ping("http://localhost:#{bypass.port}/ping")
  end

  test "request with HTTP 500 response", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 500, "Bypass Response 500")
    end)

    assert {:error, "HTTP Status 500"} = HealthCheck.ping("http://localhost:#{bypass.port}")
  end

  test "request with unexpected outage", %{bypass: bypass} do
    Bypass.down(bypass)

    assert {:error, :econnrefused} = HealthCheck.ping("http://localhost:#{bypass.port}")
  end
end
