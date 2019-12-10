defmodule ZWave.Command.BasicSet do
  @moduledoc """
  This command is used to set a target value for a device

  The supporting device must support values in the range of 0 to 99 and 0xFF
  """

  use ZWave.Command

  @type target_value :: 0..99 | 0xFF

  @type t :: %__MODULE__{
          __meta__: ZWave.Command.Meta.t(),
          target_value: target_value()
        }

  @type command_param :: {:target_value, target_value()}

  defcommand :basic_set do
    command_byte(0x01)
    command_class(ZWave.CommandClass.Basic)

    param(:target_value)
  end

  @impl true
  @spec new([command_param()]) ::
          {:ok, t()} | {:error, :invalid_target_value | :target_value_required}
  def new(params) do
    with :ok <- validate_target_value(params) do
      {:ok, struct(__MODULE__, params)}
    end
  end

  @impl ZWave.Command
  @spec params_to_binary(t()) :: binary()
  def params_to_binary(%__MODULE__{target_value: tv}) do
    <<target_value_to_byte(tv)>>
  end

  @impl ZWave.Command
  @spec params_from_binary(binary()) ::
          {:ok, [command_param()]} | {:error, :invalid_target_value}
  def params_from_binary(<<tv_byte>>) do
    case target_value_from_byte(tv_byte) do
      {:ok, tv} ->
        {:ok, target_value: tv}

      {:error, _reason} = error ->
        error
    end
  end

  defp validate_target_value(params) do
    case Keyword.get(params, :target_value) do
      nil -> {:error, :target_value_required}
      tv when tv in 0..99 when tv == 0xFF -> :ok
      _tv -> {:error, :invalid_target_value}
    end
  end

  defp target_value_to_byte(tv) when tv in 0..99 when tv == 0xFF, do: tv

  defp target_value_from_byte(byte) when byte in 1..99 when byte == 0xFF, do: {:ok, byte}
  defp target_value_from_byte(_tv), do: {:error, :invalid_target_value}
end
