defmodule ZWave.Command.Meta do
  @moduledoc """
  Meta data for a Z-Wave command

  This should be used as a read only data structure and data should be accessed
  through the functions in this module.
  """

  @opaque t :: %__MODULE__{
            source: module(),
            name: atom(),
            command_byte: byte(),
            command_class: module()
          }

  @enforce_keys [:source, :name, :command_byte, :command_class]
  defstruct source: nil, name: nil, command_byte: nil, command_class: nil

  @spec source(t()) :: module()
  def source(%__MODULE__{source: source}), do: source

  @spec name(t()) :: atom()
  def name(%__MODULE__{name: name}), do: name

  @spec command_byte(t()) :: byte()
  def command_byte(%__MODULE__{command_byte: command_byte}), do: command_byte

  @spec command_class(t()) :: module()
  def command_class(%__MODULE__{command_class: command_class}), do: command_class
end
