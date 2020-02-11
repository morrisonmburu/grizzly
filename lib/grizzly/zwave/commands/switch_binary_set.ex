defmodule Grizzly.ZWave.Commands.SwitchBinarySet do
  defstruct target_value: nil, duration: nil

  def new(opts) do
    {:ok, struct(__MODULE__, opts)}
  end

  def value_to_byte(:off), do: 0x00

  def value_from_byte(0x00), do: :off

  def handle_ack(), do: :complete

  defimpl Grizzly.ZWave.ZWaveCommand do
    alias Grizzly.ZWave.Commands.SwitchBinarySet

    def new(_command, opts) do
      SwitchBinarySet.new(opts)
    end

    def from_binary(command, <<0x25, 0x01, tv, duration>>) do
      tv = SwitchBinarySet.value_from_byte(tv)
      {:ok, struct(command, target_value: tv, duration: duration)}
    end

    def from_binary(command, <<0x25, 0x01, tv>>) do
      {:ok, struct(command, target_value: SwitchBinarySet.value_from_byte(tv))}
    end

    def to_binary(%SwitchBinarySet{target_value: tv, duration: nil}) do
      <<0x25, 0x01, SwitchBinarySet.value_to_byte(tv)>>
    end

    def to_binary(%SwitchBinarySet{target_value: tv, duration: duration}) do
      <<0x25, 0x01, tv, duration>>
    end
  end
end
