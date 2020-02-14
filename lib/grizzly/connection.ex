defmodule Grizzly.Connection do
  @moduledoc false

  alias Grizzly.Connection.Server
  alias Grizzly.ZWave.Command

  require Logger

  @type socket_opt :: {:transport, module()} | {:port, :inet.port_number()}

  @type send_opt :: {:handler, module()}

  @spec open(non_neg_integer(), [socket_opt()]) :: :ok
  def open(node_id, opts \\ []) do
    # TODO: Supervisor this!
    {:ok, pid} = Server.start_link(node_id, opts)

    :ok = Server.open(pid)

    :ok
  end

  @spec send_command(non_neg_integer(), Command.t(), [send_opt()]) :: :ok | {:ok, any()}
  def send_command(node_id, command, _opts \\ []) do
    Server.send(node_id, command)
  end

  @spec close(non_neg_integer()) :: :ok
  def close(node_id) do
    Server.close(node_id)
  end
end
