defmodule ZWave.Command.AssociationGroupingsReport do
  @moduledoc """
  This command is used to advertise the maximum number of supported
  association groups for the node

  * `:supported_groupings` - The maximum number of of associations that
     this node supports

  Reference `SDS13782 Z-Wave Management Command Class Specification.pdf`
  provided by Silicon Labs for more information.
  """
  use ZWave.Command

  alias ZWave.Command.Meta

  @type command_param :: {:supported_groupings, byte()}

  @type t :: %__MODULE__{
          __meta__: Meta.t(),
          supported_groupings: byte()
        }

  defcommand :association_groupings_report do
    command_byte(0x06)
    command_class(ZWave.CommandClass.Association)

    param(:supported_groupings)
  end

  @impl ZWave.Command
  def params_to_binary(%__MODULE__{supported_groupings: sg}) do
    {:ok, <<sg>>}
  end

  @impl ZWave.Command
  @spec params_from_binary(binary()) :: {:ok, [command_param()]}
  def params_from_binary(<<sg>>) do
    {:ok, [supported_groupings: sg]}
  end
end
