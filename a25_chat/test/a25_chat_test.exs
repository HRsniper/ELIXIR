defmodule A25ChatTest do
  use ExUnit.Case, async: true
  doctest A25Chat

  @tag :distributed
  test "send_message/2" do
    assert A25Chat.send_message(:bigdog@localhost, "hi") == :ok
  end
end
