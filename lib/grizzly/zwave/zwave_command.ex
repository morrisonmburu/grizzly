defprotocol Grizzly.ZWave.ZWaveCommand do
  @moduledoc """
  A protocol for using Elixir data structures with the Z-Wave protocol
  """

  @doc """
  Turn the command into the binary form
  """
  @spec to_binary(t()) :: binary()
  def to_binary(commnad)

  @doc """
  Try to make the command from the binary

  If the given binary is invalid according to specification return the error
  in the format of `{:error, reason}`
  """
  @spec from_binary(t(), binary()) :: {:ok, t()} | {:error, reason :: any()}
  def from_binary(command, binary)
end
