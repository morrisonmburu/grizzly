defmodule Grizzly.ConnectionTest do
  use ExUnit.Case

  alias Grizzly.Connection
  alias Grizzly.ZWave.Commands.SwitchBinarySet

  setup do
    :ok = Connection.open(1, port: 5_001, transport: GrizzlyTest.Transport.UDP)

    :ok
  end

  test "can send command" do
    {:ok, command} = SwitchBinarySet.new(target_value: :off)
    assert :ok == Connection.send_command(1, command)
  end

  test "can close the connection" do
    assert :ok == Connection.close(1)
  end
end
