defmodule ZWave.Command.AssociationRemoveTest do
  use ExUnit.Case, async: true

  alias ZWave.Command.AssociationRemove

  test "can serialize into a binary" do
    agr = %AssociationRemove{group_identifier: 0x05, node_ids: [1, 2]}
    assert {:ok, <<0x85, 0x04, 0x05, 0x01, 0x02>>} == ZWave.to_binary(agr)
  end

  test "can deserialize from a binary" do
    binary = <<0x85, 0x04, 0x05, 0x01, 0x02>>
    expected_agr = %AssociationRemove{group_identifier: 0x05, node_ids: [1, 2]}

    assert {:ok, expected_agr} == ZWave.from_binary(binary)
  end
end
