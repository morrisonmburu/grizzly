defmodule Grizzly.CommandClass.Association.Get do
  @moduledoc """
  Command module for working with ASSOCIATION GET command.

  command options:

    * `:group` - the group number
    * `:seq_number` - The sequence number for the Z/IP Packet
    * `:retries` - The number of times to resend the command (default 2)
  """

  @behaviour Grizzly.Command

  alias Grizzly.Packet
  alias Grizzly.Command.{EncodeError, Encoding}

  @type t :: %__MODULE__{
          seq_number: non_neg_integer() | nil,
          retries: non_neg_integer(),
          group: byte(),
          buffer: map()
        }

  @type opt ::
          {:seq_number, Grizzly.seq_number()}
          | {:retries, non_neg_integer()}
          | {:group, byte()}

  @enforce_keys [:group]
  defstruct seq_number: nil, retries: 2, group: nil, buffer: %{nodes: []}

  @impl true
  @spec init([opt]) :: {:ok, t()}
  def init(opts) do
    {:ok, struct(__MODULE__, opts)}
  end

  @impl true
  @spec encode(t()) :: {:ok, binary()} | {:error, EncodeError.t()}
  def encode(%__MODULE__{seq_number: seq_number, group: group} = command) do
    with {:ok, _encoded} <-
           Encoding.encode_and_validate_args(command, %{
             group: :byte
           }) do
      binary = Packet.header(seq_number) <> <<0x85, 0x02, group>>
      {:ok, binary}
    end
  end

  @impl true
  @spec handle_response(t(), Packet.t()) ::
          {:continue, t()}
          | {:done, {:error, :nack_response}}
          | {:done, {:ok, [Grizzly.Node.node_id()]}}
          | {:queued, t()}
  def handle_response(%__MODULE__{seq_number: seq_number} = command, %Packet{
        seq_number: seq_number,
        types: [:ack_response]
      }) do
    {:continue, command}
  end

  def handle_response(%__MODULE__{seq_number: seq_number, retries: 0}, %Packet{
        seq_number: seq_number,
        types: [:nack_response]
      }) do
    {:done, {:error, :nack_response}}
  end

  def handle_response(%__MODULE__{seq_number: seq_number, retries: n} = command, %Packet{
        seq_number: seq_number,
        types: [:nack_response]
      }) do
    {:retry, %{command | retries: n - 1}}
  end

  def handle_response(
        %__MODULE__{seq_number: seq_number} = command,
        %Packet{
          seq_number: seq_number,
          types: [:nack_response, :nack_waiting]
        } = packet
      ) do
    if Packet.sleeping_delay?(packet) do
      {:queued, command}
    else
      {:continue, command}
    end
  end

  def handle_response(%__MODULE__{buffer: %{nodes: nodes_so_far}}, %Packet{
        body: %{
          command_class: :association,
          command: :report,
          value: %{
            reports_to_follow: 0,
            group: group,
            nodes: nodes,
            max_nodes_supported: max_nodes_supported
          }
        }
      }) do
    {:done,
     {:ok,
      %{
        group: group,
        nodes: nodes ++ nodes_so_far,
        max_nodes_supported: max_nodes_supported
      }}}
  end

  def handle_response(
        %__MODULE__{buffer: %{nodes: nodes_so_far}} = command,
        %Packet{
          body: %{
            command_class: :association,
            command: :report,
            value: %{reports_to_follow: _n, nodes: nodes}
          }
        }
      ) do
    updated_nodes = Enum.uniq(nodes ++ nodes_so_far)

    updated_command = %__MODULE__{
      command
      | buffer: %{nodes: updated_nodes}
    }

    {:continue, updated_command}
  end

  def handle_response(%__MODULE__{} = command, _), do: {:continue, command}
end
