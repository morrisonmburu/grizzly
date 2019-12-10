defmodule ZWave.Command.BatteryGetTest do
  use ExUnit.Case, async: true

  alias ZWave.Command.BatteryGet

  test "can serialize to binary" do
    assert {:ok, <<0x80, 0x02>>} == ZWave.to_binary(%BatteryGet{})
  end

  test "can deserialize from binary" do
    assert {:ok, %BatteryGet{}} == ZWave.from_binary(<<0x80, 0x02>>)
  end
end
