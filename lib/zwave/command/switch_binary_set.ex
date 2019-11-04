defmodule ZWave.Command.SwitchBinarySet do
  @moduledoc """
  This command is used to set the on/off state of a node

  If this command has a `:duration` then this command will be serialized as
  version 2 of the command.

  If `:druation` is `nil` then this command will be serialized as version 1 of
  the command.

  For more information see
  `SDS13781 Z-Wave Application Command Class Specification.pdf` provided by
  Silicon Labs.

  """
  use ZWave.Command

  alias ZWave.CommandClass.SwitchBinary
  alias ZWave.Command.Meta
  alias ZWave.ActuatorControl
  alias ZWave.ActuatorControl.DurationSet

  @type command_opt :: {:target_value, SwitchBinary.target_value()} | {:duration, DurationSet.t()}

  @type t :: %__MODULE__{
          __meta__: Meta.t(),
          target_value: SwitchBinary.target_value(),
          duration: DurationSet.t() | nil
        }

  defcommand(:switch_binary_set) do
    command_byte(0x01)
    command_class(SwitchBinary)

    param(:target_value)
    param(:duration)
  end

  @spec params_to_binary(t()) :: {:ok, binary()}
  def params_to_binary(%__MODULE__{target_value: value, duration: nil}) do
    case SwitchBinary.target_value_to_byte(value) do
      {:ok, target_value} ->
        {:ok, <<target_value>>}

      {:error, :invalid_target_value} ->
        {:error, :encode_error}
    end
  end

  def params_to_binary(%__MODULE__{target_value: value, duration: duration}) do
    with {:ok, target_value} <- SwitchBinary.target_value_to_byte(value),
         duration = ActuatorControl.duration_to_byte(duration) do
      {:ok, <<target_value, duration>>}
    else
      _error ->
        {:error, :encode_error}
    end
  end

  @spec params_from_binary(binary()) :: {:ok, [command_opt]}
  def params_from_binary(<<target_value>>) do
    case SwitchBinary.target_value_from_byte(target_value) do
      {:ok, tv} ->
        {:ok, target_value: tv}

      {:error, :invalid_target_value} ->
        {:error, :decode_error}
    end
  end

  def params_from_binary(<<target_value, duration>>) do
    with {:ok, target_value} <- SwitchBinary.target_value_from_byte(target_value),
         {:ok, duration} <- ActuatorControl.duration_from_byte(duration, :set) do
      {:ok, target_value: target_value, duration: duration}
    else
      _error ->
        {:error, :decode_error}
    end
  end
end
