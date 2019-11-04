defmodule ZWave do
  alias ZWave.Deserializer.Default

  @spec to_binary(ZWave.Serialize.t()) :: {:ok, binary()}
  def to_binary(serializeable), do: ZWave.Serialize.to_binary(serializeable)

  @spec from_binary(binary()) :: {:ok, ZWave.Deserialize.t()} | {:error, :decode_error}
  def from_binary(binary) do
    Default.from_binary(binary)
  end

  @spec from_binary(ZWave.Deserializer.t(), binary()) :: {:ok, ZWave.Deserialize.t()}
  def from_binary(deserializer, binary), do: ZWave.Deserializer.from_binary(deserializer, binary)
end
