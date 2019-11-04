defmodule ZWave.Command.SwitchBinarySetTest do
  use ExUnit.Case, async: true

  alias ZWave.Command.SwitchBinarySet
  alias ZWave.ActuatorControl.DurationSet

  test "serializes on switch" do
    set = %SwitchBinarySet{target_value: :on}

    assert {:ok, <<0x25, 0x01, 0xFF>>} == ZWave.to_binary(set)
  end

  test "serializes off switch" do
    set = %SwitchBinarySet{target_value: :off}

    assert {:ok, <<0x25, 0x01, 0x00>>} == ZWave.to_binary(set)
  end

  test "serializes a integer target switch" do
    set = %SwitchBinarySet{target_value: 50}
    assert {:ok, <<0x25, 0x01, 0x32>>} == ZWave.to_binary(set)
  end

  test "serializes with an instant duration" do
    {:ok, duration} = DurationSet.new(:instantly)

    set = %SwitchBinarySet{target_value: :on, duration: duration}

    assert {:ok, <<0x25, 0x01, 0xFF, 0x00>>} = ZWave.to_binary(set)
  end

  test "serializes with a seconds duration" do
    {:ok, duration} = DurationSet.new(5, :seconds)

    set = %SwitchBinarySet{target_value: :on, duration: duration}

    assert {:ok, <<0x25, 0x01, 0xFF, 0x05>>} == ZWave.to_binary(set)
  end

  test "serializes with a minutes duration" do
    {:ok, duration} = DurationSet.new(5, :minutes)

    set = %SwitchBinarySet{target_value: :off, duration: duration}

    assert {:ok, <<0x25, 0x01, 0x00, 0x84>>} = ZWave.to_binary(set)
  end

  test "serializes with a factory default duration" do
    {:ok, duration} = DurationSet.new(:factory_default)

    set = %SwitchBinarySet{target_value: 75, duration: duration}

    assert {:ok, <<0x25, 0x01, 0x4B, 0xFF>>} == ZWave.to_binary(set)
  end

  test "deserialize with on value" do
    expected_set = %SwitchBinarySet{target_value: :on}
    assert {:ok, expected_set} == ZWave.from_binary(<<0x25, 0x01, 0xFF>>)
  end

  test "deserialize with off value" do
    expected_set = %SwitchBinarySet{target_value: :off}

    assert {:ok, expected_set} == ZWave.from_binary(<<0x25, 0x01, 0x00>>)
  end

  test "deserialize with integer value" do
    expected_set = %SwitchBinarySet{target_value: 33}
    assert {:ok, expected_set} == ZWave.from_binary(<<0x25, 0x01, 0x21>>)
  end

  test "deserialize with duration of instantly" do
    {:ok, duration} = DurationSet.new(:instantly)
    expected_set = %SwitchBinarySet{target_value: :on, duration: duration}

    assert {:ok, expected_set} == ZWave.from_binary(<<0x25, 0x01, 0xFF, 0x00>>)
  end

  test "deserialize with duration in seconds" do
    {:ok, duration} = DurationSet.new(127, :seconds)
    expected_set = %SwitchBinarySet{target_value: :on, duration: duration}

    assert {:ok, expected_set} == ZWave.from_binary(<<0x25, 0x01, 0xFF, 0x7F>>)
  end

  test "deserialize with duration in minutes" do
    {:ok, duration} = DurationSet.new(1, :minutes)
    expected_set = %SwitchBinarySet{target_value: :on, duration: duration}

    assert {:ok, expected_set} == ZWave.from_binary(<<0x25, 0x01, 0xFF, 0x80>>)
  end
end
