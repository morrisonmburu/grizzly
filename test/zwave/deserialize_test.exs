defmodule ZWave.DeserializeTest do
  use ExUnit.Case, async: true

  defmodule TestDeserializer do
    @behaviour ZWave.Deserializer

    def from_binary(_),
      do: ZWave.Deserialize.from_binary(%ZWave.Test.FakeCommand{}, <<1, 1>>)
  end

  test "use a custom deserializer" do
    expected_command = %ZWave.Test.FakeCommand{}
    bin = <<>>

    assert {:ok, expected_command} == ZWave.from_binary(TestDeserializer, bin)
  end
end
