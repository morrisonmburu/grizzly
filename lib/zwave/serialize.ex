defprotocol ZWave.Serialize do
  @spec to_binary(t()) :: {:ok, binary()}
  def to_binary(command)
end
