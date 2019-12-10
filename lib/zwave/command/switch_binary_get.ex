defmodule ZWave.Command.SwitchBinaryGet do
  @moduledoc """
  This command is sued to request the on/off state of a node

  The response to this is a SwitchBinaryReport command
  """

  use ZWave.Command

  @type t :: %__MODULE__{
          __meta__: ZWave.Command.Meta
        }

  alias ZWave.CommandClass.SwitchBinary

  defcommand :switch_binary_get do
    command_byte(0x02)
    command_class(SwitchBinary)
  end
end
