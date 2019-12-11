defmodule ZWave.CommandClass.DoorLock do
  use ZWave.CommandClass, name: :door_lock, command_class_byte: 0x62

  defmodule DoorHandleMode do
    @type mask :: 0x00..0x0F
    @opaque t :: %__MODULE__{
              modes: :array.array(non_neg_integer())
            }

    @enforce_keys [:modes]
    defstruct modes: nil

    @type from_binary(mask()) :: t()
    def from_binary(mask) do
      modes = make_modes_array(mask)

      %__MODULE__{modes: modes}
    end

    @spec to_binary(t()) :: mask()
    def to_binary(handle_mode) do
    end

    defp make_modes_array(mask) do
      byte = <<mask>>
      array = :array.new(size: 4, fixed: true)

      Enum.reduce(1..4, array, fn handle_number, handles_array ->
        if handle?(byte, handle_number) do
          :array.set(handle_number - 1, true, handles_array)
        else
          handles_array
        end
      end)
    end

    defp handle?(<<_::size(4), 1::size(1), _::size(3)>>, 4), do: true
    defp handle?(<<_::size(5), 1::size(1), _::size(2)>>, 3), do: true
    defp handle?(<<_::size(6), 1::size(1), _::size(1)>>, 2), do: true
    defp handle?(<<_::size(7), 1::size(1)>>, 1), do: true
    defp handle?(_, _), do: false
  end

  @type mode ::
          :unsecured
          | :unsecured_with_timeout
          | :unsecured_for_inside_door_hanldes
          | :unsecured_for_inside_door_hanldes_with_timeout
          | :unsecured_for_outside_door_hanldes
          | :unsecured_for_outside_door_hanldes_with_timeoutx
          | :unknown
          | :secured

  @type lock_modes() :: [mode()]
  def lock_modes() do
    [
      :unsecured,
      :unsecured_with_timeout,
      :unsecured_for_inside_door_hanldes,
      :unsecured_for_inside_door_hanldes_with_timeout,
      :unsecured_for_outside_door_hanldes,
      :unsecured_for_outside_door_hanldes_with_timeout,
      :unknown,
      :secured
    ]
  end
end
