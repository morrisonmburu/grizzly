defmodule ZWave.Command.SwitchBinaryGetTest do
  use ExUnit.Case, async: true

  alias ZWave.Command.SwitchBinaryGet

  test "serializes to binary" do
    assert {:ok, <<0x25, 0x02>>} == ZWave.to_binary(%SwitchBinaryGet{})
  end

  test "deserializes from binary" do
    expected_command = %SwitchBinaryGet{}
    assert {:ok, expected_command} == ZWave.from_binary(<<0x25, 0x02>>)
  end
end
