defmodule ZWave.Command.BatteryReport do
  @moduledoc """
  This command is used to report the battery level of the device
  """
  use ZWave.Command

  @typedoc """
  The battery level indicates the percentage level between 0 to 100%

  In some reports the level might be `:low_battery_warning`
  """
  @type battery_level :: 0..100 | :low_battery_warning

  @type command_param :: {:battery_level, battery_level()}

  @type t :: %__MODULE__{
          __meta__: ZWave.Command.Meta.t(),
          battery_level: battery_level()
        }

  defcommand :report do
    command_byte(0x03)
    command_class(ZWave.CommandClass.Battery)

    param(:battery_level)
  end

  @impl true
  @spec new([command_param]) ::
          {:ok, t()} | {:error, :battery_level_required | :invalid_battery_level}
  def new(opts) do
    case validate_battery_level(opts) do
      :ok ->
        {:ok, struct(__MODULE__, opts)}

      {:error, _reason} = error ->
        error
    end
  end

  @impl ZWave.Command
  def params_to_binary(%__MODULE__{battery_level: level}) do
    <<battery_level_to_byte(level)>>
  end

  @impl ZWave.Command
  def params_from_binary(<<level>>) do
    case battery_level_from_byte(level) do
      {:ok, level} ->
        {:ok, battery_level: level}

      {:error, _reason} = error ->
        error
    end
  end

  defp validate_battery_level(params) when is_list(params) do
    params
    |> Keyword.get(:battery_level)
    |> validate_battery_level()
  end

  defp validate_battery_level(:low_battery_warning), do: :ok
  defp validate_battery_level(level) when level in 0..100, do: :ok
  defp validate_battery_level(nil), do: {:error, :battery_level_required}
  defp validate_battery_level(_), do: {:error, :invalid_battery_level}

  defp battery_level_to_byte(level) when level in 0..100, do: level
  defp battery_level_to_byte(:low_battery_warning), do: 0xFF

  defp battery_level_from_byte(level) when level in 0..100, do: {:ok, level}
  defp battery_level_from_byte(0xFF), do: {:ok, :low_battery_warning}
  defp battery_level_from_byte(_byte), do: {:error, :invalid_battery_level}
end
