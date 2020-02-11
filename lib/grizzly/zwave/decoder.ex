defmodule Grizzly.ZWave.Decoder do
  @moduledoc false

  alias Grizzly.ZWave.Command

  @spec from_binary(binary) :: {:ok, Command.t()}
  def from_binary(<<0x25, 0x01, _rest::binary>> = binary),
    do: decode(Grizzly.ZWave.Commands.SwitchBinarySet, binary)

  defp decode(module, binary) do
    Command.from_binary(struct(module), binary)
  end
end
