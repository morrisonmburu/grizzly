defmodule ZWave.Command.AssociationRemove do
  @moduledoc """
  This command is used to advertise the destination of a given association
  group

  * `:group_identifier` - the group id of which nodes should be removed from
  * `:node_ids` - list of node ids to remove from the specified group

  ## Interpreting parameter values

  If `:group_identifier` and the number of node ids are both greater than `0`, this
  command will remove all node ids in the list from the specified group. (Mandatory V1).

  If `:group_identifier` is greater than `0` and there are no node ids in the `:node_ids`
  list then all node ids associated with that group are removed. (Recommended V1)

  If `:group_identifier` is `0` and the number of node ids in the `:node_ids` list
  is greater than `0` then remove the specified node ids from all association
  groups. (Reserved V1, Mandatory V2)

  If `:group_identifier` is `0` and there are no node ids in the `:node_ids` list
  then remove the all node ids from all association groups. Basically this is
  resetting all associations. (Reserved V1, Mandatory V2)

  Reference `SDS13782 Z-Wave Management Command Class Specification.pdf`
  provided by Silicon Labs for more information.
  """

  use ZWave.Command

  @type command_param :: {:node_ids, [byte()]} | {:group_identifier, byte()}

  @type t :: %__MODULE__{
          __meta__: ZWave.Command.Meta.t(),
          group_identifier: byte(),
          node_ids: [byte()]
        }

  defcommand :association_remove do
    command_byte(0x04)
    command_class(ZWave.CommandClass.Association)

    param(:group_identifier)
    param(:node_ids, default: [])
  end

  @impl ZWave.Command
  @spec params_to_binary(t()) :: {:ok, binary()}
  def params_to_binary(%__MODULE__{group_identifier: group_identifier, node_ids: node_ids}) do
    node_ids_bin = :erlang.list_to_binary(node_ids)
    {:ok, <<group_identifier>> <> node_ids_bin}
  end

  @impl ZWave.Command
  @spec params_from_binary(binary()) :: {:ok, [command_param]}
  def params_from_binary(<<agi, node_ids::binary>>) do
    {:ok, [group_identifier: agi, node_ids: :erlang.binary_to_list(node_ids)]}
  end
end
