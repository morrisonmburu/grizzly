defmodule ZWave.Command do
  @moduledoc """
  This module is useful for building new Z-Wave commands

  When building a Z-Wave command there are 3 pieces that have to be defined:

  1. The data structure
  2. The serialization of the data structure
  3. The deserialization of the data structure

  Every command will have both static and dynamic data. Static data is called
  `meta` data. That is the byte of the command, the name of the command, and
  the command class module that is associated to the command.

  The dynamic data is called a `param` and a command can have 0 or more params.

  While it is possible to define these data structures completely by hand this
  module exposes a DSL for generating these data structures and implementing
  some support for (de)serialization. The reasons behind developing a DSL are:
  correctness, consistency, and productivity.

  Here is how to define a 0 param command:

  ```
  defmodule MyCommand do
    use ZWave.Command

    defcommand :my_command do
      command_byte(0xFF)
      command_class(ZWave.CommandClass.MyCommandClass)
    end
  end
  ```

  From this we are able to generate the correct meta data and implement the
  (de)serialization logic from `ZWave.Serialize` and `ZWave.Deserialize`
  protocols.

  Here is how to define 1 or more param command:

  ```
  defmodule MyCommandWithParams do
    use ZWave.Command

    defcommand :my_command_with_params do
      command_byte(0xFF)
      command_class(ZWave.CommandClass.MyCommandClass)

      param(:my_param1)
      param(:my_param2)
      params(:my_paramN)
    end

    def params_from_binary(<<my_param1, my_param2, my_paramN>>) do
      {:ok, my_param1: my_param1, my_param2: my_param2, my_paramN: my_paramN}
    end

    def params_to_binary(%__MODULE__{my_param1: mp1, my_param2: mp2, my_paramN mpN}) do
      {:ok, <<mp1, mp2, mpN>>}
    end
  end
  ```

  We are able to generate the data structure and wrapper implementation of the
  (de)serialization protocols. When you have params in your command you will
  need to implement the `params_to_binary/1` and `params_from_binary/1`
  callbacks. The reason for this is because we cannot derive how each param
  should be encoded and decoded.
  """

  alias ZWave.Command.Meta

  @type t :: module() | %{__meta__: Meta.t()}

  @doc """
  A callback to wrap the encoding of the command params in the
  `ZWave.Serialize` protocol.

  This callback will take the command and return the binary string
  of the encoded params.
  """
  @callback params_to_binary(ZWave.Serialize.t()) :: {:ok, binary()} | {:error, any()}

  @doc """
  A callback to wrap the decoding of the command params in the
  `ZWave.Deserialize` protocol.

  This callback will take the part of the binary that is the params
  and output the command params to build the command with.
  """
  @callback params_from_binary(ZWave.Deserialize.t()) :: {:ok, keyword()} | {:error, any()}

  @optional_callbacks params_to_binary: 1, params_from_binary: 1

  defmacro __using__(_) do
    quote do
      import ZWave.Command, only: [defcommand: 2]
    end
  end

  @doc """
  Define a new Z-Wave command

  Takes the `:name` of the the command followed by the command definition
  macros: `command_byte/1`, `command_class/1`, or `param/1/2`.

  ```
  defmodule MyCommand do
    use ZWave.Command

    defcommand :the_name do
      command_byte(0x01)
      command_class(MyCommandClass)

      param(:param1)
      param(:param_with_default, default: :hello)
    end
  end
  ```

  This generates a data structure, ensures teh needed meta data is given, and
  provides wrappers to `ZWave.Serialize` and `ZWave.Deserialize`. See the
  summary for more details.
  """
  defmacro defcommand(name, block) do
    quote do
      Module.register_attribute(__MODULE__, :command_meta, [])
      Module.register_attribute(__MODULE__, :command_params, accumulate: true)

      Module.put_attribute(__MODULE__, :command_meta, ZWave.Command.MetaBuilder.new())

      ZWave.Command.__put_command_meta__(__MODULE__, :source, __MODULE__)
      ZWave.Command.__put_command_meta__(__MODULE__, :name, unquote(name))

      @behaviour ZWave.Command
      import ZWave.Command

      unquote(block)

      meta =
        case ZWave.Command.MetaBuilder.build(@command_meta) do
          {:ok, meta} ->
            meta

          {:error, error} ->
            raise(
              ArgumentError,
              """
              Invalid Command Meta Data for #{inspect(__MODULE__)}

                To fix this please ensure none of the fields below are nil or match what is
                expected in ZWave.Command.Meta.opt().

                #{inspect(error)}
              """
            )
        end

      # @derive {Inspect, except: [:__meta__]}
      defstruct [__meta__: meta] ++ @command_params

      if length(@command_params) == 0 do
        defimpl ZWave.Serialize do
          def to_binary(command) do
            meta = ZWave.Command.meta(command)
            module = ZWave.Command.Meta.source(meta)
            command_byte = ZWave.Command.Meta.command_byte(meta)
            command_class = ZWave.Command.Meta.command_class(meta)

            command_class_byte = ZWave.CommandClass.command_class_byte(command_class)

            {:ok, <<command_class_byte, command_byte>>}
          end
        end

        defimpl ZWave.Deserialize do
          def from_binary(command, <<_, _>>) do
            {:ok, command}
          end
        end
      else
        defimpl ZWave.Serialize do
          def to_binary(command) do
            meta = ZWave.Command.meta(command)
            module = ZWave.Command.Meta.source(meta)
            command_byte = ZWave.Command.Meta.command_byte(meta)
            command_class = ZWave.Command.Meta.command_class(meta)

            command_class_byte = ZWave.CommandClass.command_class_byte(command_class)

            case apply(module, :params_to_binary, [command]) do
              {:ok, binary} ->
                {:ok, <<command_class_byte, command_byte>> <> binary}
            end
          end
        end

        defimpl ZWave.Deserialize do
          def from_binary(command, <<_, _, rest::binary>>) do
            meta = ZWave.Command.meta(command)
            module = ZWave.Command.Meta.source(meta)

            case apply(module, :params_from_binary, [rest]) do
              {:ok, command_opts} -> {:ok, struct(command, command_opts)}
              error -> error
            end
          end
        end
      end
    end
  end

  @doc """
  Specify the command byte that is given in the Z-Wave specification
  """
  defmacro command_byte(byte) do
    quote do
      ZWave.Command.__put_command_meta__(__MODULE__, :command_byte, unquote(byte))
    end
  end

  @doc """
  Specify the command module that the command is associated with
  """
  defmacro command_class(command_class) do
    quote do
      ZWave.Command.__put_command_meta__(__MODULE__, :command_class, unquote(command_class))
    end
  end

  @doc """
  Specify the parameter name
  """
  defmacro param(param_name) do
    quote do
      ZWave.Command.__put_command_param__(__MODULE__, unquote(param_name))
    end
  end

  @doc """
  Specify the parameter name with options

  Options include:

  * `:default` - The default value of the param if it not set when creating the
     command data structure

  """
  defmacro param(param_name, opts) do
    quote do
      ZWave.Command.__put_command_param__(__MODULE__, unquote(param_name), unquote(opts))
    end
  end

  @doc """
  Get the meta data struct from the command
  """
  @spec meta(ZWave.Command.t()) :: Meta.t()
  def meta(command) do
    command.__meta__
  end

  def __put_command_meta__(module, meta_key, meta_value) do
    meta = Module.get_attribute(module, :command_meta)

    case ZWave.Command.MetaBuilder.put(meta, meta_key, meta_value) do
      {:ok, meta} ->
        Module.put_attribute(module, :command_meta, meta)

      {:error, :invalid_meta_field} ->
        raise(
          ArgumentError,
          """
          Invalid meta field for command #{inspect(module)}

            It looks like you are trying to set the #{inspect(meta_key)} meta field
            for your command.

            The valid fields are:

            - :command_byte
            - :command_class
            - :name
            - :source


            See ZWave.Command.Meta module for more information
          """
        )
    end
  end

  def __put_command_param__(module, command_param, opts \\ []) do
    default = Keyword.get(opts, :default)
    Module.put_attribute(module, :command_params, {command_param, default})
  end
end
