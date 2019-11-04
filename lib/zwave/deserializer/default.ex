defmodule ZWave.Deserializer.Default do
  @moduledoc """
  The default deserializer


  This deserializer can be used along with a custom deserializer:

  ```
  defmodule MyDeserializer do
    @behaviour ZWave.Deserializer

    def from_binary(<<0x05, _rest::binary>>) do
      {:ok, %MyCommandImplementation{}}
    end

    def from_binary(binary), do: ZWave.Deserializer.Default.from_binary(binary)
  end
  ```
  """

  @behaviour ZWave.Deserializer

  alias ZWave.Deserialize

  alias ZWave.Command.{
    AssociationGet,
    AssociationGroupingsReport,
    AssociationRemove,
    AssociationReport,
    AssociationSet,
    AssociationSupportedGroupingsGet,
    SwitchBinaryGet,
    SwitchBinarySet,
    SwitchBinaryReport
  }

  @spec from_binary(binary()) :: {:ok, ZWave.Deserialize.t()} | {:error, :decode_error}
  def from_binary(binary) do
    case get_command(binary) do
      {:ok, command} -> Deserialize.from_binary(command, binary)
      error -> error
    end
  end

  # switch_binary
  defp get_command(<<0x25, 0x01, _rest::binary>>), do: {:ok, %SwitchBinarySet{}}
  defp get_command(<<0x25, 0x02, _rest::binary>>), do: {:ok, %SwitchBinaryGet{}}
  defp get_command(<<0x25, 0x03, _rest::binary>>), do: {:ok, %SwitchBinaryReport{}}

  # association
  defp get_command(<<0x85, 0x01, _rest::binary>>), do: {:ok, %AssociationSet{}}
  defp get_command(<<0x85, 0x02, _rest::binary>>), do: {:ok, %AssociationGet{}}
  defp get_command(<<0x85, 0x03, _rest::binary>>), do: {:ok, %AssociationReport{}}
  defp get_command(<<0x85, 0x04, _rest::binary>>), do: {:ok, %AssociationRemove{}}
  defp get_command(<<0x85, 0x05, _rest::binary>>), do: {:ok, %AssociationSupportedGroupingsGet{}}
  defp get_command(<<0x85, 0x06, _rest::binary>>), do: {:ok, %AssociationGroupingsReport{}}
  defp get_command(_), do: {:error, :decode_error}
end
