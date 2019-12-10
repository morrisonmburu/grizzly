defmodule ZWave.Command.BasicGet do
  use ZWave.Command

  @type t :: %__MODULE__{
          __meta__: ZWave.Command.Meta.t()
        }

  defcommand :basic_get do
    command_byte(0x02)
    command_class(ZWave.CommandClass.Basic)
  end
end
