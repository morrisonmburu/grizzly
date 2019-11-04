defprotocol ZWave.Deserialize do
  @spec from_binary(t(), binary()) :: {:ok, t()} | {:error, :decode_error}
  def from_binary(data, binary)
end
