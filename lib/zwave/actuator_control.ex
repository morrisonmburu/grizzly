defmodule ZWave.ActuatorControl do
  @moduledoc """
  An actuator device may support one or more actuator command classes.

  The actuator control group is made up of:

  - Barrier Operator Command Class
  - Basic Command Class
  - Binary Switch Command Class
  - Color Switch Command Class
  - Door Lock Command Class
  - Mulilevel Switch Command Class
  - Simple AV Command Class
  - Sound Switch Command Class
  - Thermostat Setpoint Command Class
  - Thermostat Mode Command Class
  - Window Covering Command Class

  Actuator classes can support the idea of of a duration between the device's
  current state and target state. There are two encodings for duration
  parameters. See `ZWave.ActuatorControl.Duration` for more information.

  """

  alias ZWave.ActuatorControl.{DurationSet, DurationReport}

  @type duration_type :: :set | :report

  @spec duration_from_byte(byte, duration_type) :: {:ok, DurationSet.t() | DurationReport.t()}
  def duration_from_byte(byte, :set), do: DurationSet.from_byte(byte)
  def duration_from_byte(byte, :report), do: DurationReport.from_byte(byte)

  @spec duration_to_byte(DurationSet.t() | DurationReport.t()) :: byte()
  def duration_to_byte(%DurationSet{} = duration_set), do: DurationSet.to_byte(duration_set)

  def duration_to_byte(%DurationReport{} = duration_report),
    do: DurationReport.to_byte(duration_report)
end
