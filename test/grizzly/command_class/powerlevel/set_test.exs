defmodule Grizzly.CommandClass.Powerlevel.Set.Test do
  use ExUnit.Case, async: true

  alias Grizzly.Packet
  alias Grizzly.CommandClass.Powerlevel.Set
  alias Grizzly.CommandClass.Powerlevel
  alias Grizzly.Command.EncodeError

  describe "implements the Grizzly command behaviour" do
    test "initializes the command state" do
      {:ok, command} = Set.init(power_level: :normal_power, timeout: 1)

      assert %Set{power_level: :normal_power, timeout: 1} == command
    end

    test "encodes correctly" do
      {:ok, command} = Set.init(power_level: :normal_power, timeout: 1, seq_number: 0x06)
      {:ok, level} = Powerlevel.encode_power_level(:normal_power)
      binary = <<35, 2, 128, 208, 6, 0, 0, 3, 2, 0, 0x73, 0x01, level, 1>>

      assert {:ok, binary} == Set.encode(command)
    end

    test "encodes incorrectly" do
      {:ok, command} = Set.init(power_level: :blue, timeout: 0xFF, seq_number: 0x06)

      error = EncodeError.new({:invalid_argument_value, :power_level, :blue, Set})

      assert {:error, error} == Set.encode(command)
    end

    test "handles an ack response" do
      {:ok, command} = Set.init(power_level: :normal_power, timeout: 1, seq_number: 0x01)
      packet = Packet.new(seq_number: 0x01, types: [:ack_response])

      assert {:done, :ok} == Set.handle_response(command, packet)
    end

    test "handles a nack response" do
      {:ok, command} =
        Set.init(power_level: :normal_power, timeout: 1, seq_number: 0x01, retries: 0)

      packet = Packet.new(seq_number: 0x01, types: [:nack_response])

      assert {:done, {:error, :nack_response}} == Set.handle_response(command, packet)
    end

    test "handles retries" do
      {:ok, command} = Set.init(power_level: :normal_power, timeout: 1, seq_number: 0x01)
      packet = Packet.new(seq_number: 0x01, types: [:nack_response])

      assert {:retry, _command} = Set.handle_response(command, packet)
    end

    test "handles queued for wake up nodes" do
      {:ok, command} = Set.init(power_level: :normal_power, timeout: 1, seq_number: 0x01)

      packet =
        Packet.new(seq_number: 0x01, types: [:nack_response, :nack_waiting])
        |> Packet.put_expected_delay(5000)

      assert {:queued, ^command} = Set.handle_response(command, packet)
    end

    test "handles nack waiting when delay is 1 or less" do
      {:ok, command} = Set.init(power_level: :normal_power, timeout: 1, seq_number: 0x01)

      packet =
        Packet.new(seq_number: 0x01, types: [:nack_response, :nack_waiting])
        |> Packet.put_expected_delay(1)

      assert {:continue, ^command} = Set.handle_response(command, packet)
    end

    test "handles responses" do
      {:ok, command} = Set.init(power_level: :normal_power, timeout: 1)

      assert {:continue, _} = Set.handle_response(command, %{})
    end
  end
end
