defmodule Grizzly.ZWave.Commands.NodeListGet do
  @moduledoc """
  Module for the NODE_LIST_GET command

  This command has no parameters
  """
  @behaviour Grizzly.ZWave.Command

  alias Grizzly.ZWave.Command

  @impl true
  def new(_) do
    # TODO: validate opts
    command = %Command{
      name: :node_list_get,
      command_class_byte: 0x52,
      command_byte: 0x01,
      impl: __MODULE__
    }

    {:ok, command}
  end
end
