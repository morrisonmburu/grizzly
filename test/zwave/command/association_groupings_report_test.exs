defmodule ZWave.Command.AssociationGroupingsReportTest do
  use ExUnit.Case, async: true

  alias ZWave.Command.AssociationGroupingsReport

  test "can serialize into a binary" do
    agr = %AssociationGroupingsReport{supported_groupings: 0x05}

    assert {:ok, <<0x85, 0x06, 0x05>>} == ZWave.to_binary(agr)
  end

  test "can deserialize from a binary" do
    expected_agr = %AssociationGroupingsReport{supported_groupings: 0x09}
    binary = <<0x85, 0x06, 0x09>>

    assert {:ok, expected_agr} ==
             ZWave.from_binary(binary)
  end
end
