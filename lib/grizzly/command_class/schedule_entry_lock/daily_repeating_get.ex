defmodule Grizzly.CommandClass.ScheduleEntryLock.DailyRepeatingGet do
  @moduledoc """
  Command for working with SCHEDULE_ENTRY_LOCK command class DAILY_REPEATING_GET command

  Command Options:
    
    * `:user_id` - a number for the user id
    * `:slot_id` - the slot id for the code
    * `:seq_number` - The sequence number used in the Z/IP packet
    * `:retries` - The number of attempts to send the command (default 2)
  """
  @behaviour Grizzly.Command

  alias Grizzly.Packet
  alias Grizzly.Command.{EncodeError, Encoding}
  alias Grizzly.CommandClass.ScheduleEntryLock

  @type t :: %__MODULE__{
          user_id: non_neg_integer,
          slot_id: non_neg_integer,
          seq_number: Grizzly.seq_number(),
          retries: non_neg_integer()
        }

  @type opt ::
          {:seq_number, Grizzly.seq_number()}
          | {:retries, non_neg_integer()}
          | {:user_id, non_neg_integer()}
          | {:slot_id, non_neg_integer()}

  defstruct seq_number: nil, retries: 2, user_id: nil, slot_id: nil

  @spec init([opt]) :: {:ok, t}
  def init(opts) do
    {:ok, struct(__MODULE__, opts)}
  end

  @spec encode(t) :: {:ok, binary} | {:error, EncodeError.t()}
  def encode(%__MODULE__{seq_number: seq_number, user_id: user_id, slot_id: slot_id} = command) do
    with {:ok, _encoded} <-
           Encoding.encode_and_validate_args(command, %{
             user_id: :byte,
             slot_id: :byte
           }) do
      binary = Packet.header(seq_number) <> <<0x4E, 0x0E, user_id, slot_id>>
      {:ok, binary}
    end
  end

  @spec handle_response(t, Packet.t()) ::
          {:continue, t()}
          | {:done, {:error, :nack_response}}
          | {:done, {:ok, ScheduleEntryLock.daily_repeating_report()}}
          | {:retry, t()}
          | {:queued, t()}
  def handle_response(
        %__MODULE__{seq_number: seq_number} = command,
        %Packet{
          seq_number: seq_number,
          types: [:ack_response]
        }
      ) do
    {:continue, command}
  end

  def handle_response(
        %__MODULE__{seq_number: seq_number, retries: 0},
        %Packet{
          seq_number: seq_number,
          types: [:nack_response]
        }
      ) do
    {:done, {:error, :nack_response}}
  end

  def handle_response(
        %__MODULE__{seq_number: seq_number, retries: n} = command,
        %Packet{
          seq_number: seq_number,
          types: [:nack_response]
        }
      ) do
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

  def handle_response(
        _,
        %Packet{
          body: %{
            command_class: :schedule_entry_lock,
            command: :daily_repeating_report,
            value: value
          }
        }
      ) do
    {:done, {:ok, value}}
  end

  def handle_response(command, _), do: {:continue, command}
end
