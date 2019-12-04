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

  @type command_param ::
          {:target_value, SwitchBinary.target_value()} | {:duration, DurationSet.t()}

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

  @impl true
  @spec new([command_param]) ::
          {:ok, t()}
          | {:error, :invalid_target_value | :invalid_duration | :target_value_required}
  def new(params) do
    with :ok <- validate_target_value(params),
         :ok <- validate_duration(params) do
      {:ok, struct(__MODULE__, params)}
    end
  end

  @impl ZWave.Command
  @spec params_to_binary(t()) :: binary()
  def params_to_binary(%__MODULE__{target_value: value, duration: nil}) do
    {:ok, target_value} = SwitchBinary.target_value_to_byte(value)
    <<target_value>>
  end

  def params_to_binary(%__MODULE__{target_value: value, duration: duration}) do
    {:ok, target_value} = SwitchBinary.target_value_to_byte(value)
    duration = ActuatorControl.duration_to_byte(duration)
    <<target_value, duration>>
  end

  @impl ZWave.Command
  @spec params_from_binary(binary()) :: {:ok, [command_param]}
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

  defp validate_target_value(params) do
    case Keyword.get(params, :target_value) do
      nil ->
        {:error, :target_value_required}

      target_value when target_value in 0..99 or target_value in [0xFF, :on, :off, :unknown] ->
        :ok

      _ ->
        {:error, :invalid_target_value}
    end
  end

  defp validate_duration(params) do
    case Keyword.get(params, :duration) do
      nil -> :ok
      %DurationSet{} -> :ok
      _ -> {:error, :invalid_duration}
    end
  end
end
