defmodule Grizzly.CommandHandlers.Table do
  alias Grizzly.CommandHandlers.DefaultSet
  alias Grizzly.ZWave.Command
  alias Grizzly.ZWave.Commands.SwitchBinarySet

  @spec lookup(Command.t()) :: {:ok, module()}
  def lookup(%SwitchBinarySet{}), do: {:ok, DefaultSet}
end
