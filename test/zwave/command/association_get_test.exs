defmodule ZWave.Command.AssociationGetTest do
  use ExUnit.Case, async: true

  alias ZWave.Command.AssociationGet

  test "can serialize into a binary" do
    ag = %AssociationGet{group_identifier: 0x03}

    assert {:ok, <<0x85, 0x02, 0x03>>} == ZWave.to_binary(ag)
  end

  test "can deserialize from a binary" do
    expected_ag = %AssociationGet{group_identifier: 0x05}
    binary = <<0x85, 0x02, 0x05>>

    assert {:ok, expected_ag} == ZWave.from_binary(binary)
  end
end
