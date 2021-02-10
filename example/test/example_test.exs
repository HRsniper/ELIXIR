defmodule SendingProcess do
  def run(pid) do
    send(pid, :ping)
  end
end

defmodule ExampleTest do
  use ExUnit.Case
  doctest Example

  import ExUnit.CaptureIO

  setup_all do
    {:ok, recipient: :world}
  end

  test "greets :pass", state do
    assert Example.hello() == state[:recipient]
  end

  test "Expected return true :pass" do
    assert Example.hello() == :world
  end

  test "Expected return false :fail" do
    assert Example.hello() == :world2
  end

  test "Expected return false :pass" do
    refute Example.hello() == :world2
  end

  test "receives ping :pass" do
    SendingProcess.run(self())
    assert_received :ping
  end

  test "outputs Hello World :pass" do
    assert capture_io(fn -> IO.puts("Hello World") end) == "Hello World\n"
  end

end
