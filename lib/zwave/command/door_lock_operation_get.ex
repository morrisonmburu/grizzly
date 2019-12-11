defmodule ZWave.Command.DoorLockOperationGet do
  @moduledoc """
  This command is used to request the state of a door lock device

  The `DoorLockOperationReport` command must be returned in response to
  this command.
  """
  use ZWave.Command

  @type t :: %__MODULE__{
          __meta__: ZWave.Command.Meta.t()
        }

  defcommand :door_lock_operation_get do
    command_byte(0x02)
    command_class(ZWave.CommandClass.DoorLock)
  end
end
