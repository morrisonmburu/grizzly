defmodule Grizzly.CommandClass.NodeProvisioning.Set do
  @moduledoc """
  Command Options:

    * `:dsk` - A DSK string for the device see `Grizzly.DSK`
      for more details
    * `:meta_extensions` - a list of `Grizzly.SmartStart.MetaExtension.t()`
    * `:seq_number` - The sequence number of the Z/IP Packet
    * `:retries` - The number of times to try to send the command (default 2)
  """
  @behaviour Grizzly.Command

  alias Grizzly.{Packet, DSK}
  alias Grizzly.Command.{EncodeError, Encoding}
  alias Grizzly.SmartStart.MetaExtension

  @type t :: %__MODULE__{
          dsk: DSK.dsk_string(),
          meta_extensions: [MetaExtension.t()],
          seq_number: Grizzly.seq_number(),
          retries: non_neg_integer()
        }

  @type opt ::
          {:dsk, DSK.dsk_string()}
          | {:meta_extensions, [Grizzly.SmartStart.MetaExtension.t()]}
          | {:seq_number, Grizzly.seq_number()}
          | {:retries, non_neg_integer()}

  defstruct dsk: nil, meta_extensions: [], seq_number: nil, retries: 2

  @spec init([opt]) :: {:ok, t}
  def init(opts) do
    {:ok, struct(__MODULE__, opts)}
  end

  @spec encode(t) :: {:ok, binary} | {:error, EncodeError.t()}
  def encode(%__MODULE__{dsk: _dsk, seq_number: seq_number} = command) do
    with {:ok, encoded} <-
           Encoding.encode_and_validate_args(command, %{
             dsk: {:encode_with, DSK, :string_to_binary},
             meta_extensions: {:encode_with, MetaExtension, :extensions_to_binary}
           }) do
      binary =
        Packet.header(seq_number) <>
          <<0x78, 0x01, seq_number, 0x10>> <> encoded.dsk <> encoded.meta_extensions

      {:ok, binary}
    end
  end

  @spec handle_response(t, Packet.t()) ::
          {:continue, t} | {:done, {:error, :nack_response}} | {:done, :ok}
  def handle_response(%__MODULE__{seq_number: seq_number}, %Packet{
        seq_number: seq_number,
        types: [:ack_response]
      }) do
    {:done, :ok}
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

  def handle_response(command, _), do: {:continue, command}
end
