defmodule Grizzly.Connection.Server do
  @moduledoc false

  use GenServer

  alias Grizzly.{ConnectionRegistry, CommandHandlers, ZIPGateway}
  alias Grizzly.Connection.Socket
  alias Grizzly.ZWave.Commands.ZIPPacket

  alias Grizzly.CommandRunner

  defmodule State do
    defstruct transport: nil, host: nil, port: nil, socket: nil
  end

  def start_link(node_id, opts) do
    host = ZIPGateway.host_for_node(node_id)
    name = ConnectionRegistry.via_name(node_id)
    opts = Keyword.merge([host: host, port: ZIPGateway.port()], opts)

    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def open(connection) do
    name = ConnectionRegistry.via_name(connection)
    GenServer.call(name, :open)
  end

  @spec send(non_neg_integer() | pid(), atom()) :: :ok
  def send(socket, command) do
    name = ConnectionRegistry.via_name(socket)
    GenServer.call(name, {:send, command})
  end

  def close(socket) do
    name = ConnectionRegistry.via_name(socket)
    GenServer.stop(name)
  end

  def init(opts) do
    transport = get_transport(opts)
    host = Keyword.fetch!(opts, :host)
    port = Keyword.fetch!(opts, :port)

    {:ok, %State{transport: transport, host: host, port: port}}
  end

  def handle_call(:open, _from, state) do
    %State{transport: transport, host: host, port: port} = state

    case transport.open(host, port) do
      {:ok, socket} ->
        conn_socket = Socket.from_raw(socket)
        {:reply, :ok, %{state | socket: conn_socket}}
    end
  end

  def handle_call({:send, command}, from, state) do
    case CommandHandlers.lookup(command) do
      {:ok, command_handler} ->
        packet = ZIPPacket.with_zwave_command(command, seq_number: 10)
        binary = ZIPPacket.to_binary(packet)

        {:ok, command} =
          CommandRunner.start_link(
            handler: command_handler,
            zip_packet: packet,
            waiter: from
          )

        socket = Socket.put_command(state.socket, command)

        case state.transport.send(Socket.to_raw(state.socket), binary) do
          :ok ->
            {:noreply, %{state | socket: socket}}
        end
    end
  end

  def handle_info(data, state) do
    case state.transport.parse_response(data) do
      {:ok, zip_packet_binary} ->
        {:ok, zip_packet} = ZIPPacket.from_binary(zip_packet_binary)
        new_socket = Socket.handle_zip_packet(state.socket, zip_packet)

        {:noreply, %{state | socket: new_socket}}
    end
  end

  def terminate(:normal, state) do
    socket = Socket.to_raw(state.socket)
    state.transport.close(socket)
  end

  def get_transport(opts) do
    case Keyword.get(opts, :transport) do
      nil ->
        Application.get_env(:grizzly, :transport, GrizzlyTest.Transport.UDP)

      transport ->
        transport
    end
  end
end
