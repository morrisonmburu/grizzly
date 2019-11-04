defmodule ZWave.Command.AssociationReport do
  @moduledoc """
  This command is used to advertise the destination of a given association
  group

  * `:group_identifier` - the group id for the associated node destinations
  * `:max_nodes_support` - the number of nodes that can be associated in the group
  * `:reports_to_follow` - the number of `AssociationReports` to follow due to
    the number of nodes that are associated being too large for a single frame
  * `:node_ids` - the nodes that are associated destinations for the specified
    group

  Reference `SDS13782 Z-Wave Management Command Class Specification.pdf`
  provided by Silicon Labs for more information.
  """

  use ZWave.Command

  @type command_param ::
          {:group_identifier, byte()}
          | {:max_nodes_supported, byte()}
          | {:reports_to_follow, byte()}
          | {:node_ids, [byte()]}

  @type t :: %__MODULE__{
          __meta__: ZWave.Command.Meta.t(),
          group_identifier: byte(),
          max_nodes_supported: byte(),
          reports_to_follow: byte(),
          node_ids: [byte()]
        }

  defcommand :association_report do
    command_byte(0x03)
    command_class(ZWave.CommandClass.Association)

    param(:group_identifier)
    param(:max_nodes_supported)
    param(:reports_to_follow)
    param(:node_ids, default: [])
  end

  @impl ZWave.Command
  @spec params_to_binary(t()) :: {:ok, binary()}
  def params_to_binary(%__MODULE__{
        group_identifier: agi,
        max_nodes_supported: mns,
        reports_to_follow: rtf,
        node_ids: node_ids
      }) do
    node_ids_bin = :erlang.list_to_binary(node_ids)
    {:ok, <<agi, mns, rtf>> <> node_ids_bin}
  end

  @impl ZWave.Command
  @spec params_from_binary(binary) :: {:ok, [command_param]}
  def params_from_binary(<<agi, mns, rtf, node_ids::binary>>) do
    node_ids_list = :erlang.binary_to_list(node_ids)

    {:ok,
     [
       group_identifier: agi,
       max_nodes_supported: mns,
       reports_to_follow: rtf,
       node_ids: node_ids_list
     ]}
  end
end
