defmodule Grizzly.Connection.Socket do
  alias Grizzly.ZWave.Commands.ZIPPacket
  alias Grizzly.CommandRunner

  @type t :: %__MODULE__{
          socket: :inet.socket(),
          commands: list()
        }

  @enforce_keys [:socket]
  defstruct socket: nil, commands: []

  def from_raw(socket), do: %__MODULE__{socket: socket}

  def to_raw(%__MODULE__{socket: socket}), do: socket

  @spec put_command(t(), pid()) :: t()
  def put_command(socket, command) do
    %{socket | commands: [command | socket.commands]}
  end

  def handle_zip_packet(socket, zip_packet) do
    commands =
      Enum.reduce(socket.commands, [], fn command, acc ->
        if ZIPPacket.ack_response?(zip_packet) do
          case CommandRunner.handle_ack(command, zip_packet.seq_number) do
            :complete ->
              acc
          end
        else
          [command | acc]
        end
      end)

    %{socket | commands: commands}
  end
end
