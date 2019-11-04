defmodule ZWave.Command.AssociationSet do
  @moduledoc """
  This command is used to add destinations to a given associated group

  * `:group_identifier` - the group id too associate the nodes to
  * `:node_ids` - a list of node ids that should be associated in the group
     specified above

  Reference `SDS13782 Z-Wave Management Command Class Specification.pdf`
  provided by Silicon Labs for more information.
  """
  use ZWave.Command

  alias ZWave.Command.Meta

  @type command_param :: {:group_identifier, byte()} | {:node_ids, [byte()]}

  @type t :: %__MODULE__{
          __meta__: Meta.t(),
          group_identifier: byte(),
          node_ids: [byte()]
        }

  defcommand :association_set do
    command_byte(0x01)
    command_class(ZWave.CommandClass.Association)

    param(:group_identifier)
    param(:node_ids)
  end

  @impl ZWave.Command
  @spec params_to_binary(t()) :: {:ok, binary()}
  def params_to_binary(%__MODULE__{group_identifier: agi, node_ids: node_ids}) do
    node_ids_bin = :erlang.list_to_binary(node_ids)
    {:ok, <<agi>> <> node_ids_bin}
  end

  @impl ZWave.Command
  @spec params_from_binary(binary()) :: {:ok, [command_param]}
  def params_from_binary(<<agi, node_ids_bin::binary>>) do
    node_ids = :erlang.binary_to_list(node_ids_bin)
    {:ok, group_identifier: agi, node_ids: node_ids}
  end
end
