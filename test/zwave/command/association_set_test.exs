defmodule ZWave.Command.AssociationSetTest do
  use ExUnit.Case, async: true

  alias ZWave.Command.AssociationSet

  test "can serialize into a binary" do
    as = %AssociationSet{group_identifier: 0x03, node_ids: [100, 20, 5]}

    assert {:ok, <<0x85, 0x01, 0x03, 0x64, 0x14, 0x05>>} == ZWave.to_binary(as)
  end

  test "can deserialize from a binary" do
    expected_as = %AssociationSet{group_identifier: 0x05, node_ids: [6, 5, 4]}
    binary = <<0x85, 0x01, 0x05, 0x06, 0x05, 0x04>>

    assert {:ok, expected_as} == ZWave.from_binary(binary)
  end
end
