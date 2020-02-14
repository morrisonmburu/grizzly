defmodule Grizzly.Init do
  use GenServer

  alias Grizzly.{Connection, Events}
  alias Grizzly.ZWave.Commands.NodeListGet
  require Logger

  def start_link(_) do
    GenServer.start(__MODULE__, nil)
  end

  def init(_) do
    {:ok, %{}, {:continue, :connect_to_controller}}
  end

  def handle_continue(:connect_to_controller, state) do
    case Connection.open(1, port: 5001) do
      :ok ->
        Events.broadcast(:controller_connected)
        Logger.info("Opened connection to controller")
        {:noreply, state, {:continue, :get_node_list}}
    end
  end

  def handle_continue(:get_node_list, state) do
    Logger.warn("Getting node list")
    Grizzly.send_command(1, )
    {:noreply, state}
  end
end
