defmodule ZWave.CommandClass.DoorLock.DoorHandleModeTest do
  use ExUnit.Case, async: true

  alias ZWave.CommandClass.DoorLock.DoorHandleMode

  test "from binary when no handle modes are selected" do
    handle_mode = DoorHandleMode.from_binary(0x0F)

    assert [] == DoorHandleMode.list_handles(handle_mode)
  end

  test "from binary when all handle modes are selected"

  test "from binary when handle 4 is selected"
  test "from binary when handle 3 is selected"
  test "from binary when handle 2 is selected"
  test "from binary when handle 1 is selected"
end
