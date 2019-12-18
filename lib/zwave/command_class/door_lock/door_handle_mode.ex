defmodule ZWave.CommandClass.DoorLock.DoorHandleMode do
  @type mask :: 0x00..0x0F

  @opaque t :: %__MODULE__{
            modes: :array.array(non_neg_integer())
          }

  @enforce_keys [:modes]
  defstruct modes: nil

  @doc """
  Make a `DoorHandleMode.t()` from a bitmask
  """
  @spec from_binary(mask()) :: t()
  def from_binary(mask) do
    modes = modes_array_from_mask(mask)

    %__MODULE__{modes: modes}
  end

  @doc """
  Turn the `DoorHandleMode.t()` into a bitmask
  """
  @spec to_binary(t()) :: mask()
  def to_binary(handle_mode) do
    handle_mode
    |> mask_modes_array()
  end

  def list_modes(%__MODULE__{modes: modes}),
    do:
      modes
      |> :array.to_orddict()
      |> Enum.filter(fn {_ix, m} -> m != :undefined end)
      |> Enum.map(fn {ix, _} -> ix + 1 end)

  defp mask_modes_array(modes_array) do
    modes_array
    |> :array.to_orddict()
    |> Enum.reduce(0, fn
      {_ix, :undefined}, mask -> mask
      {0, true}, mask -> mask + 1
      {1, true}, mask -> mask + 2
      {3, true}, mask -> mask + 4
      {4, true}, mask -> mask + 8
    end)
  end

  defp modes_array_from_mask(mask) do
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
