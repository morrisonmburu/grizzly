defmodule ZWave.ActuatorControl.Duration do
  @moduledoc """
  Some actuator command classes allow controlling the duration for when a
  node should reach its set target value

  There are two encodings for the duration one for set commands and one for
  report commands.

  The main difference is the report encoding privdes a byte for an unknown
  time before the node reaches its target value. That means in practice
  validation for these are slightly different.

  These difference are handled in`ZWave.ActuatorControl.DurationSet` and
  `ZWave.ActuatorControl.DurationReport` respectively.
  """

  @type duration_time :: :instantly | :factory_default | :unknown_duration | 1..127
  @type resolution :: :seconds | :minutes
end
