defmodule ZWave.CommandClass do
  @moduledoc """
  A behaviour for Z-Wave command classes

  Usage:

  ```
  defmodule MyCommandClass do
    use ZWave.CommandClass, name: :my_command_class, command_class_byte: 0xFF
  end
  ```
  """
  @typedoc """
  A module that implements the `ZWave.CommandClass` behaviour
  """
  @type t :: module()

  @callback command_class_byte() :: byte()

  @callback name() :: atom()

  @doc """
  Given a command class module get the name for the command class
  """
  @spec name(t()) :: atom()
  def name(module) do
    apply(module, :name, [])
  end

  @doc """
  Given a command class module get the command class byte
  """
  @spec command_class_byte(t()) :: byte()
  def command_class_byte(module) do
    apply(module, :command_class_byte, [])
  end

  defmacro __using__(opts) do
    quote do
      @behaviour ZWave.CommandClass

      def name() do
        Keyword.get(unquote(opts), :name)
      end

      def command_class_byte() do
        Keyword.get(unquote(opts), :command_class_byte)
      end
    end
  end
end
