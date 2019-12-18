defmodule ZWave.CommandClass.DoorLock do
  use ZWave.CommandClass, name: :door_lock, command_class_byte: 0x62

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
