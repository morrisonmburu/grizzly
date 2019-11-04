defmodule ZWave.Deserializer do
  @moduledoc """
  Deserializer behaviour

  This module defines a behaviour for a module to act as a Z-Wave deserializer.

  That means the module implements `from_binary/1` which takes a binary from
  the Z-Wave network and produces some Elixir data structure from that binary.

  There is a default provided deserailizer via `ZWave.Deserializer.Default`
  which `ZWave.from_binary/1` uses under the hood.

  You can combine your own deserializer along with the default one inorder to
  maintain support for all the Z-Wave commands but add customization to parts
  of your deserialization logic. An example of this is in
  `ZWave.Deserailizer.Default` summary. This is useful for when you want to
  implement custom commands.
  """
  @type t :: module()

  @callback from_binary(binary()) :: {:ok, ZWave.Deserialize.t()} | {:error, :decode_error}

  @spec from_binary(t(), binary) :: {:ok, ZWave.Deserialize.t()} | {:error, :decode_error}
  def from_binary(deserializer, binary), do: deserializer.from_binary(binary)
end
