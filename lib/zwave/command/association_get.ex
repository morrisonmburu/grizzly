defmodule ZWave.Command.AssociationGet do
  @moduledoc """
  This command is used to add destinations to a given associated group

  * `:group_identifier` - the group id to get the `ZWave.AssociationReport`
    for the group

  Reference `SDS13782 Z-Wave Management Command Class Specification.pdf`
  provided by Silicon Labs for more information.
  """
  use ZWave.Command

  alias ZWave.Command.Meta

  @type command_param :: {:group_identifier, byte()}

  @type t :: %__MODULE__{
          __meta__: Meta.t(),
          group_identifier: byte()
        }

  defcommand :association_get do
    command_byte(0x02)
    command_class(ZWave.CommandClass.Association)

    param(:group_identifier)
  end

  @impl ZWave.Command
  @spec params_to_binary(t()) :: {:ok, binary()}
  def params_to_binary(%__MODULE__{group_identifier: group_identifier}) do
    {:ok, <<group_identifier>>}
  end

  @impl ZWave.Command
  @spec params_from_binary(binary()) :: {:ok, [command_param()]}
  def params_from_binary(<<group_identifier>>) do
    {:ok, group_identifier: group_identifier}
  end
end
