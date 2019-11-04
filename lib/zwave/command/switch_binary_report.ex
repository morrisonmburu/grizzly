defmodule ZWave.Command.SwitchBinaryReport do
  @moduledoc """
  This command is used to advertise the on/off state of a node

  In version 1 of this command the only parameter is `:current_value` where as
  in version 2 of this command there are three parameters: `:current_value`,
  `:target_value`, and `:duration`.

  """
  use ZWave.Command

  alias ZWave.Command.Meta
  alias ZWave.CommandClass.SwitchBinary
  alias ZWave.ActuatorControl
  alias ZWave.ActuatorControl.DurationReport

  @type report_value :: :on | :off | :unknown

  @type command_opt ::
          {:target_value, report_value()}
          | {:current_value, report_value()}
          | {:duration, DurationReport.t()}

  @type t :: %__MODULE__{
          __meta__: Meta.t(),
          target_value: report_value(),
          current_value: report_value(),
          duration: DurationReport.t()
        }

  defcommand :switch_binary_report do
    command_byte(0x03)
    command_class(SwitchBinary)

    param(:current_value)
    param(:target_value)
    param(:duration)
  end

  @spec params_to_binary(t()) :: {:ok, binary()} | {:error, :invalid_report_value}
  def params_to_binary(%__MODULE__{current_value: current_value, duration: nil, target_value: nil}) do
    case report_value_to_byte(current_value) do
      {:ok, current_value} ->
        {:ok, <<current_value>>}

      error ->
        error
    end
  end

  def params_to_binary(%__MODULE__{
        target_value: target_value,
        duration: duration,
        current_value: current_value
      }) do
    with {:ok, target_value_byte} <- report_value_to_byte(target_value),
         {:ok, current_value_byte} <- report_value_to_byte(current_value),
         duration_byte <- ActuatorControl.duration_to_byte(duration) do
      {:ok, <<current_value_byte, target_value_byte, duration_byte>>}
    end
  end

  @spec params_from_binary(binary()) :: {:ok, [command_opt()]} | {:error, :invalid_report_value}
  def params_from_binary(<<current_value_byte>>) do
    case report_value_from_byte(current_value_byte) do
      {:ok, current_value} ->
        {:ok, current_value: current_value}

      error ->
        error
    end
  end

  def params_from_binary(<<current_value_byte, target_value_byte, duration_byte>>) do
    with {:ok, current_value} <- report_value_from_byte(current_value_byte),
         {:ok, target_value} <- report_value_from_byte(target_value_byte),
         {:ok, duration_report} <- ActuatorControl.duration_from_byte(duration_byte, :report) do
      {:ok, current_value: current_value, target_value: target_value, duration: duration_report}
    end
  end

  defp report_value_to_byte(:on), do: {:ok, 0xFF}
  defp report_value_to_byte(:off), do: {:ok, 0x00}
  defp report_value_to_byte(:unknown), do: {:ok, 0xFE}
  defp report_value_to_byte(_), do: {:error, :invalid_report_value}

  defp report_value_from_byte(0x00), do: {:ok, :off}
  defp report_value_from_byte(0xFF), do: {:ok, :on}
  defp report_value_from_byte(0xFE), do: {:ok, :unknown}
  defp report_value_from_byte(_), do: {:error, :invalid_report_value}
end
