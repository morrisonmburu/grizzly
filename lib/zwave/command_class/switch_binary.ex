defmodule ZWave.CommandClass.SwitchBinary do
  use ZWave.CommandClass, name: :switch_binary, command_class_byte: 0x25

  @typedoc """
  The value of the target value of the switch.

  This value is either a range between 0 and 99, 0xFF (255) or the atoms
  `:on` or `:off`. The range is for better support between binary switches
  and multilevel switches when using teh Basic Set command.
  """
  @type target_value :: 0..99 | 0xFF | :on | :off | :unknown

  @spec target_value_to_byte(target_value()) :: {:ok, byte()} | {:error, :invalid_target_value}
  def target_value_to_byte(:on), do: {:ok, 0xFF}
  def target_value_to_byte(:off), do: {:ok, 0x00}
  def target_value_to_byte(0xFF), do: {:ok, 0xFF}
  def target_value_to_byte(byte) when byte in 0..99, do: {:ok, byte}
  def target_value_to_byte(_), do: {:error, :invalid_target_value}

  @spec target_value_from_byte(byte()) :: {:ok, target_value()} | {:error, :invalid_target_value}
  def target_value_from_byte(0xFF), do: {:ok, :on}
  def target_value_from_byte(0x00), do: {:ok, :off}
  def target_value_from_byte(byte) when byte in 1..99, do: {:ok, byte}

  def target_value_from_byte(_), do: {:error, :invalid_target_value}
end
