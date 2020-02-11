defmodule Grizzly do
  alias Grizzly.Connection
  alias Grizzly.ZWave.Command

  @spec send_command(non_neg_integer(), Command.t()) :: :ok
  def send_command(node_id, command, _opts \\ []) do
    Connection.send_command(node_id, command)
  end
end
