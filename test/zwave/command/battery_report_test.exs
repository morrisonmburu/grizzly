defmodule ZWave.Command.BatteryReportTest do
  use ExUnit.Case, async: true

  alias ZWave.Command.BatteryReport

  describe "creation" do
    test "when all is okay" do
      expected_report = %BatteryReport{battery_level: 75}
      assert {:ok, expected_report} == BatteryReport.new(battery_level: 75)
    end

    test "when battery level is invalid" do
      assert {:error, :invalid_battery_level} == BatteryReport.new(battery_level: 130)
    end

    test "when battery level is nil" do
      assert {:error, :battery_level_required} == BatteryReport.new([])
    end
  end

  test "serialize the report" do
    {:ok, report} = BatteryReport.new(battery_level: 96)
    assert {:ok, <<0x80, 0x03, 0x60>>} == ZWave.to_binary(report)
  end

  describe "deserialize" do
    test "when all is okay" do
      {:ok, expected_report} = BatteryReport.new(battery_level: 96)
      assert {:ok, expected_report} == ZWave.from_binary(<<0x80, 0x03, 0x60>>)
    end

    test "when battery level is invalid" do
      assert {:error, :invalid_battery_level} == ZWave.from_binary(<<0x80, 0x03, 0xBC>>)
    end
  end
end
