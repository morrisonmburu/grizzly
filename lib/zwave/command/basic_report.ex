defmodule ZWave.Command.BasicReport do
  @moduledoc """
  This report is used to report the status of the primary functionality of the
  device
  """
  use ZWave.Command

  alias ZWave.Command.BasicReport.Value

  @type t :: %__MODULE__{
          __meta__: ZWave.Command.Meta.t(),
          current_value: Value.t()
        }

  @type command_param :: {:current_value, Value.t()}

  defcommand :basic_report do
    command_byte(0x03)
    command_class(ZWave.CommandClass.Basic)

    param(:current_value)
  end

  @spec new([command_param]) ::
          {:ok, t()} | {:error, :current_value_required | :invalid_report_value}
  def new(params) do
    with :ok <- validate_current_value(params) do
      {:ok, struct(__MODULE__, params)}
    end
  end

  @spec params_to_binary(t()) :: binary()
  def params_to_binary(%__MODULE__{current_value: cv}) do
    <<Value.as_level(cv)>>
  end

  @spec params_from_binary(binary()) :: {:ok, [command_param()]} | {:error, :invalid_report_value}
  def params_from_binary(<<current_value_byte>>) do
    with {:ok, %Value{} = value} <- Value.from_byte(current_value_byte) do
      {:ok, current_value: value}
    end
  end

  defp validate_current_value(params) do
    case Keyword.get(params, :current_value) do
      nil ->
        {:ok, :current_value_required}

      %Value{} ->
        :ok

      _value ->
        {:error, :invalid_report_value}
    end
  end
end
