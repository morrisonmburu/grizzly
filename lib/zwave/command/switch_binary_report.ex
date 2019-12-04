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

  @type command_param ::
          {:target_value, report_value()}
          | {:current_value, report_value()}
          | {:duration, DurationReport.t()}

  @type t :: %__MODULE__{
          __meta__: Meta.t(),
          target_value: report_value(),
          current_value: report_value() | nil,
          duration: DurationReport.t() | nil
        }

  defcommand :switch_binary_report do
    command_byte(0x03)
    command_class(SwitchBinary)

    param(:current_value)
    param(:target_value)
    param(:duration)
  end

  @impl true
  @spec new([command_param]) ::
          {:ok, t()}
          | {:error,
             :duration_required
             | :target_value_required
             | :invalid_duration
             | :current_value_required}
  def new(params) do
    with :ok <- validate_current_value(params),
         :ok <- validate_target_value_and_duration(params) do
      {:ok, struct(__MODULE__, params)}
    end
  end

  @impl ZWave.Command
  @spec params_to_binary(t()) :: binary()
  def params_to_binary(%__MODULE__{current_value: current_value, duration: nil, target_value: nil}) do
    {:ok, current_value} = report_value_to_byte(current_value)
    <<current_value>>
  end

  def params_to_binary(%__MODULE__{
        target_value: target_value,
        duration: duration,
        current_value: current_value
      }) do
    {:ok, target_value_byte} = report_value_to_byte(target_value)
    {:ok, current_value_byte} = report_value_to_byte(current_value)
    duration_byte = ActuatorControl.duration_to_byte(duration)

    <<current_value_byte, target_value_byte, duration_byte>>
  end

  @impl ZWave.Command
  @spec params_from_binary(binary()) :: {:ok, [command_param()]} | {:error, :invalid_report_value}
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

  defp validate_current_value(params) do
    Keyword.get(params, :current_value, {:error, :current_value_required})
  end

  defp validate_target_value_and_duration(params) do
    duration = Keyword.get(params, :duration)
    target_value = Keyword.get(params, :target_value)

    duration_target_value_valid(duration, target_value)
  end

  defp duration_target_value_valid(nil, nil), do: :ok
  defp duration_target_value_valid(%DurationReport{}, tv) when not is_nil(tv), do: :ok
  defp duration_target_value_valid(nil, _tv), do: {:error, :duration_required}
  defp duration_target_value_valid(%DurationReport{}, nil), do: {:error, :target_value_required}

  defp duration_target_value_valid(duration, _)
       when not is_nil(duration),
       do: {:error, :invalid_duration}
end
