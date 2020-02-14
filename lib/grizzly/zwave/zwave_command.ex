defprotocol Grizzly.ZWave.Command do
  @moduledoc """
  Data struct and behaviour for working with Z-Wave commands
  """

  @type params :: Keyword.t()

  @type t :: %__MODULE__{
          name: atom(),
          command_class_name: atom(),
          command_class_byte: byte(),
          command_byte: byte(),
          params: Keyword.t(),
          impl: module()
        }

  @enforce_keys [:name, :command_class_name, :command_byte, :command_class_byte, :impl]
  defstruct name: nil,
            params: [],
            command_class_name: nil,
            command_byte: nil,
            command_class_byte: nil,
            impl: nil

  @callback new(params :: keyword()) :: {:ok, t()} | {:error, reason :: any()}

  @doc """
  Try to make the command from the binary

  If the given binary is invalid according to specification return the error
  in the format of `{:error, reason}`
  """
  @callback from_binary(binary()) :: {:ok, t()} | {:error, reason :: any()}

  @callback encode_param(atom(), term()) :: byte() | {16, non_neg_integer()} | {32, non_neg_integer()} | nil

  @callback decode_params(binary()) :: keyword()

  @option_callbacks [encode_param: 2, decode_params: 1]

  def to_binary(command) do
    header = <<command.command_class_byte, command.command_byte>>

    Enum.reduce(command.params, header, fn {param_name, param_value}, binary ->
      header <> <<command.impl.encode_param(param_name, param_value)>>
    end)
  end

  def param(command, param, default \\ nil) do
    Keyword.get(command, :param, default)
  end

  def param!(command, param) do
    try  do
      Keyword.fetch!(command, param)
    rescue
      KeyError ->
        raise KeyError, """
        It looks like you tried to get the #{inspect(param)} from your command.

        Here is a list of available params for your command:

        """ <> list_of_command_params(command)
    end
  end

  defp list_of_command_params(command) do
    Enum.reduce(command.params, "", fn {param_name, _}, str_list ->
      <> "  * #{inspect(param_name)}\n"
    end)
  end
end
