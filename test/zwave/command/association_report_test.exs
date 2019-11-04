defmodule ZWave.Command.AssociationTest do
  use ExUnit.Case, async: true

  alias ZWave.Command.AssociationReport

  test "can serialize into a binary" do
    agr = %AssociationReport{
      group_identifier: 0x05,
      node_ids: [1, 2],
      max_nodes_supported: 5,
      reports_to_follow: 10
    }

    assert {:ok, <<0x85, 0x03, 0x05, 0x05, 0x0A, 0x01, 0x02>>} == ZWave.to_binary(agr)
  end

  test "can deserialize from a binary" do
    binary = <<0x85, 0x03, 0x05, 0x05, 0x01, 0x05, 0x02>>

    expected_agr = %AssociationReport{
      group_identifier: 0x05,
      node_ids: [0x05, 0x02],
      max_nodes_supported: 0x05,
      reports_to_follow: 0x01
    }

    assert {:ok, expected_agr} == ZWave.from_binary(binary)
  end
end
