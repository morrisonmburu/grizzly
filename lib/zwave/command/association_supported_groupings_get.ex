defmodule ZWave.Command.AssociationSupportedGroupingsGet do
  @moduledoc """
  This command is used to request the number of association groups this node supports

  Reference `SDS13782 Z-Wave Management Command Class Specification.pdf`
  provided by Silicon Labs for more information.
  """

  use ZWave.Command

  @type t :: %__MODULE__{
          __meta__: ZWave.Command.Meta.t()
        }

  defcommand :association_supported_groupings_get do
    command_byte(0x05)
    command_class(ZWave.CommandClass.Association)
  end
end
