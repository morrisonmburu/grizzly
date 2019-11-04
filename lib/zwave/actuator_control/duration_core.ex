defmodule ZWave.ActuatorControl.DurationCore do
  @moduledoc false
  alias ZWave.ActuatorControl.Duration

  @spec byte_from_duration_and_resolution(Duration.duration_time(), Duration.resolution()) ::
          byte()
  def byte_from_duration_and_resolution(:instantly, _), do: 0x00
  def byte_from_duration_and_resolution(:factory_default, _), do: 0xFF
  def byte_from_duration_and_resolution(:unknown_duration, _), do: 0xFE
  def byte_from_duration_and_resolution(time, :seconds), do: time
  def byte_from_duration_and_resolution(time, :minutes), do: time - 0x81

  @spec get_minutes(0x01..0xFE) :: 1..127
  def get_minutes(0x80), do: 1
  def get_minutes(int), do: int - 0x81

  @spec validate_duration_time(Duration.duration_time()) :: :ok | {:error, :invalid_duration_time}
  def validate_duration_time(duration_time)
      when duration_time in [:instantly, :factory_default],
      do: :ok

  def validate_duration_time(duration_time) when duration_time in 1..127, do: :ok
  def validate_duration_time(_), do: {:error, :invalid_duration_time}

  @spec validate_resolution(Duration.resolution() | nil) :: :ok | {:error, :invalid_resolution}
  def validate_resolution(nil), do: :ok
  def validate_resolution(:seconds), do: :ok
  def validate_resolution(:minutes), do: :ok
  def validate_resolution(_), do: {:error, :invalid_resolution}
end
