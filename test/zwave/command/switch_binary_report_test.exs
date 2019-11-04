defmodule ZWave.Command.SwitchBinaryReportTest do
  use ExUnit.Case, async: true

  alias ZWave.Command.SwitchBinaryReport
  alias ZWave.ActuatorControl.DurationReport

  describe "being serialized" do
    test "when v1 current target off" do
      report = %SwitchBinaryReport{current_value: :off}

      expected_binary = <<0x25, 0x03, 0x00>>

      assert {:ok, expected_binary} == ZWave.to_binary(report)
    end

    test "when v1 current target unknown" do
      report = %SwitchBinaryReport{current_value: :unknown}

      expected_binary = <<0x25, 0x03, 0xFE>>

      assert {:ok, expected_binary} == ZWave.to_binary(report)
    end

    test "when v1 current target on" do
      report = %SwitchBinaryReport{current_value: :on}

      expected_binary = <<0x25, 0x03, 0xFF>>

      assert {:ok, expected_binary} == ZWave.to_binary(report)
    end

    test "when v2 duration instant" do
      {:ok, duration} = DurationReport.new(:instantly)
      report = %SwitchBinaryReport{current_value: :on, target_value: :off, duration: duration}

      expected_binary = <<0x25, 0x03, 0xFF, 0x00, 0x00>>

      assert {:ok, expected_binary} == ZWave.to_binary(report)
    end

    test "when v2 duration in seconds" do
      {:ok, duration} = DurationReport.new(1, :seconds)
      report = %SwitchBinaryReport{current_value: :on, target_value: :off, duration: duration}

      expected_binary = <<0x25, 0x03, 0xFF, 0x00, 0x01>>

      assert {:ok, expected_binary} == ZWave.to_binary(report)
    end

    test "when v2 duration in minutes" do
      {:ok, duration} = DurationReport.new(5, :minutes)
      report = %SwitchBinaryReport{current_value: :on, target_value: :off, duration: duration}

      expected_binary = <<0x25, 0x03, 0xFF, 0x00, 0x84>>

      assert {:ok, expected_binary} == ZWave.to_binary(report)
    end
  end

  describe "being deserialized" do
    test "when v1 current value is off" do
      report_bin = <<0x25, 0x03, 0x00>>

      expected_report = %SwitchBinaryReport{current_value: :off}

      assert {:ok, expected_report} == ZWave.from_binary(report_bin)
    end

    test "when v1 current value is on" do
      report_bin = <<0x25, 0x03, 0xFF>>

      expected_report = %SwitchBinaryReport{current_value: :on}

      assert {:ok, expected_report} == ZWave.from_binary(report_bin)
    end

    test "when v1 current value is unknown" do
      report_bin = <<0x25, 0x03, 0xFE>>

      expected_report = %SwitchBinaryReport{current_value: :unknown}

      assert {:ok, expected_report} == ZWave.from_binary(report_bin)
    end

    test "when v2 duration instant" do
      report_bin = <<0x25, 0x03, 0x00, 0xFF, 0x00>>
      {:ok, duration} = DurationReport.new(:instantly)

      expected_report = %SwitchBinaryReport{
        current_value: :off,
        target_value: :on,
        duration: duration
      }

      assert {:ok, expected_report} == ZWave.from_binary(report_bin)
    end

    test "when v2 duration seconds" do
      report_bin = <<0x25, 0x03, 0x00, 0xFF, 0x05>>
      {:ok, duration} = DurationReport.new(5, :seconds)

      expected_report = %SwitchBinaryReport{
        current_value: :off,
        target_value: :on,
        duration: duration
      }

      assert {:ok, expected_report} == ZWave.from_binary(report_bin)
    end

    test "when v2 duration minutes" do
      report_bin = <<0x25, 0x03, 0x00, 0xFF, 0x89>>
      {:ok, duration} = DurationReport.new(8, :minutes)

      expected_report = %SwitchBinaryReport{
        current_value: :off,
        target_value: :on,
        duration: duration
      }

      assert {:ok, expected_report} == ZWave.from_binary(report_bin)
    end
  end
end
