defmodule ZWave.Command.MetaBuilder do
  @moduledoc """
  A module to help build `Meta.t()` for a Z-Wave command

  This module provides validation and error handling to ensure that all command
  meta data is valid.

  The primary way to make a new meta data structure is through the `build/1`
  function.

  Meta fields are:

  - `:source` - The source module of the Z-Wave command
  - `:name` - The name of the command
  - `:command_byte` - The byte for the command as outlined in the Z-Wave
    specification
  - `:command_class` - The command class module for the command
  """
  alias ZWave.Command.Meta

  @metafields [
    :source,
    :name,
    :command_byte,
    :command_class
  ]

  @type meta_field :: :source | :name | :command_byte | :command_class

  @opaque t :: %__MODULE__{
            source: module() | nil,
            name: atom() | nil,
            command_byte: byte() | nil,
            command_class: module() | nil
          }

  defstruct source: nil, name: nil, command_byte: nil, command_class: nil

  @spec new() :: t()
  def new() do
    %__MODULE__{}
  end

  @spec put(t(), meta_field(), value :: any()) :: {:ok, t()} | {:error, :invalid_meta_field}
  def put(meta, key, value) when key in @metafields do
    {:ok, Map.put(meta, key, value)}
  end

  def put(_, _, _), do: {:error, :invalid_meta_field}

  @spec build(t()) :: {:ok, Meta.t()} | {:error, [{meta_field(), value :: any()}]}
  def build(meta_builder) do
    validation_list =
      meta_builder
      |> Map.from_struct()
      |> Enum.map(&validate_field/1)

    split_validation_list =
      :lists.partition(
        fn
          {:invalid, _field} -> false
          _ -> true
        end,
        validation_list
      )

    case split_validation_list do
      {ok_meta_opts, []} ->
        {:ok, struct(Meta, ok_meta_opts)}

      {_, errors} ->
        errors =
          errors
          |> Enum.map(fn {:invalid, field} -> field end)

        {:error, errors}
    end
  end

  defp validate_field({_, nil} = field), do: {:invalid, field}
  defp validate_field({:source, module} = source) when is_atom(module), do: source
  defp validate_field({:name, n} = name) when is_atom(n), do: name

  defp validate_field({:command_byte, cbyte} = command_byte) when cbyte in 0x00..0xFF,
    do: command_byte

  defp validate_field({:command_class, cc} = command_class) when is_atom(cc), do: command_class
  defp validate_field(field), do: {:invalid, field}
end
