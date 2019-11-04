defmodule ZWave.ActuatorControl.DurationSet do
  @moduledoc """
  This is used when using command classes that are part of the actuator control
  command class to set the duration in time when a node should reach its
  target value.
  """

  alias ZWave.ActuatorControl.{DurationCore, Duration}

  @type t :: %__MODULE__{
          duration_time: Duration.duration_time(),
          resolution: Duration.resolution() | nil
        }

  @enforce_keys [:duration_time]
  defstruct duration_time: nil, resolution: nil

  @spec new(Duration.duration_time(), Duration.resolution() | nil) ::
          {:ok, t()} | {:error, :invalid_duration_time | :invalid_resolution}
  def new(time, resolution \\ nil) do
    with :ok <- DurationCore.validate_duration_time(time),
         :ok <- DurationCore.validate_resolution(resolution) do
      {:ok, %__MODULE__{duration_time: time, resolution: resolution}}
    end
  end

  @doc """
  Get a `DurationSet.t()` from a byte
  """
  @spec from_byte(byte()) :: {:ok, t()}
  def from_byte(0x00), do: new(:instantly)

  def from_byte(byte) when byte in 0x01..0x7F,
    do: new(byte, :seconds)

  def from_byte(byte) when byte in 0x80..0xFE,
    do: new(DurationCore.get_minutes(byte), :minutes)

  def from_byte(0xFF), do: new(:factory_default)

  @spec to_byte(t()) :: byte()
  def to_byte(%__MODULE__{duration_time: time, resolution: resolution}) do
    DurationCore.byte_from_duration_and_resolution(time, resolution)
  end
end
