defmodule ZWave.Command.BatteryGet do
  @moduledoc """
  This command is used to request the level of the battery

  The BATTERY_REPORT command must be the response to this command
  """

  use ZWave.Command

  @type t :: %__MODULE__{
          __meta__: ZWave.Command.Meta
        }

  defcommand :battery_get do
    command_byte(0x02)
    command_class(ZWave.CommandClass.Battery)
  end
end
