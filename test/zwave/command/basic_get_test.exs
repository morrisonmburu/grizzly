defmodule ZWave.Command.BasicGetTest do
  use ExUnit.Case, async: true

  alias ZWave.Command.BasicGet

  test "can serialize to binary" do
    assert {:ok, <<0x20, 0x02>>} == ZWave.to_binary(%BasicGet{})
  end

  test "can deserialize from binary" do
    assert {:ok, %BasicGet{}} == ZWave.from_binary(<<0x20, 0x02>>)
  end
end
