defmodule ZWave.Command.DoorLockOperationReport do
  use ZWave.Command

  alias ZWave.CommandClass.DoorLock

  @type t :: %__MODULE__{
    __meta__: ZWave.Command.Meta.t(),
    docker_lock_mode: DoorLock.mode(),
    outside_door_handles_mode: DoorLock.DoorHandleMode.t()
  }

  defcommand :door_lock_operation_report do
    command_byte(0x03)
    command_class(DoorLock)

    param(:door_lock_mode)
    param(:outside_door_handles_mode)
    param(:inside_door_handles_mode)
    param(:door_condition)
    params(:lock_timeout_minues)
    params(:lock_timeout_seconds)
  end

  def new(params) do
    with :ok <- validate_params(params) do
      {:ok, struct(__MODULE__, params)}
    end
  end

  defp validate_params(params) do
    params
    |> Enum.map(&do_validate_params/1)
    |> Enum.reduce_while(:ok, fn
      :ok, :ok -> {:cont, :ok}
      {:error, _reason} = error, _ok -> {:halt, error}
    end)
  end

  defp do_validate_params({:door_lock_mode, mode}) do
    if mode in DoorLock.lock_modes() do
      :ok
    else
      {:error, :invalid_mode}
    end
  end
end
