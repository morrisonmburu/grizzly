defmodule ZWave.Command.AssociationSupportedGroupingsGetTest do
  use ExUnit.Case, async: true

  alias ZWave.Command.AssociationSupportedGroupingsGet

  test "can serialize into a binary" do
    asgg = %AssociationSupportedGroupingsGet{}

    assert {:ok, <<0x85, 0x05>>} == ZWave.to_binary(asgg)
  end

  test "can deserialize from a binary" do
    expected_asgg = %AssociationSupportedGroupingsGet{}
    binary = <<0x85, 0x05>>

    assert {:ok, expected_asgg} ==
             ZWave.from_binary(binary)
  end
end
