defmodule ZWave.Command.BasicSetTest do
  use ExUnit.Case, async: true

  alias ZWave.Command.BasicSet

  describe "creation" do
    test "when target value is an integer between 0 and 99" do
      Enum.each(0..99, fn tv ->
        assert {:ok, %BasicSet{target_value: tv}} == BasicSet.new(target_value: tv)
      end)
    end

    test "when target value is 0xFF" do
      assert {:ok, %BasicSet{target_value: 0xFF}} == BasicSet.new(target_value: 0xFF)
    end

    test "when target value is nil" do
      assert {:error, :target_value_required} == BasicSet.new([])
    end

    test "when target value is not valid" do
      Enum.each([100, "99"], fn tv ->
        assert {:error, :invalid_target_value} == BasicSet.new(target_value: tv)
      end)
    end
  end

  describe "serialization to binary" do
    test "When target value is a number between 0 and 99" do
      Enum.each(0..99, fn tv ->
        {:ok, basic_set} = BasicSet.new(target_value: tv)
        assert {:ok, <<0x20, 0x01, tv>>} == ZWave.to_binary(basic_set)
      end)
    end

    test "when target value is 0xFF" do
      {:ok, basic_set} = BasicSet.new(target_value: 0xFF)
      assert {:ok, <<0x20, 0x01, 0xFF>>} == ZWave.to_binary(basic_set)
    end
  end

  describe "deserialization from binary" do
    test "when all is okay" do
      {:ok, expected_basic_set} = BasicSet.new(target_value: 0x05)
      assert {:ok, expected_basic_set} == ZWave.from_binary(<<0x20, 0x01, 0x05>>)
    end

    test "when target value is invalid" do
      assert {:error, :invalid_target_value} == ZWave.from_binary(<<0x20, 0x01, 0xBB>>)
    end
  end
end
