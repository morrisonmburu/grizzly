defmodule ZWave.Command.BasicReport.Value do
  @moduledoc """
  The value reported by `BasicReport` command.

  There are two different representations of the value reported. That is a
  "level" or a "state". This module is helpful for handing both
  representations and transforming both levels and states into and from binary.
  """
  @type state :: :off | :on | :unknown

  @opaque t() :: %__MODULE__{
            v: byte()
          }

  @enforce_keys [:v]
  defstruct v: nil

  @doc """
  Make a `BasicReport.Value` from a byte
  """
  @spec from_byte(byte()) :: {:ok, t()} | {:error, :invalid_report_value_state}
  def from_byte(byte) when byte in 0x00..0x63 when byte in [0xFF, 0xFE] do
    {:ok, struct(__MODULE__, v: byte)}
  end

  def from_byte(_byte), do: {:error, :invalid_basic_report_value_byte}

  @doc """
  Make a `BasicReport.Value` from a `state()`
  """
  @spec from_state(state()) :: {:ok, t()} | {:error, :invalid_report_value_state}
  def from_state(state) when state in [:off, :on, :unknown] do
    value = state_to_byte(state)

    {:ok, struct(__MODULE__, v: value)}
  end

  def from_state(_state) do
    {:error, :invalid_report_value_state}
  end

  @doc """
  Make the `BasicReport.Value.t()` into a `state()` value
  """
  @spec as_state(t()) :: state()
  def as_state(%__MODULE__{v: value}) do
    state_from_byte(value)
  end

  @doc """
  Make the `BasicReport.Value.t()` into a `level` value (byte)
  """
  @spec as_level(t()) :: byte()
  def as_level(%__MODULE__{v: value}) do
    value
  end

  defp state_to_byte(:on), do: 0xFF
  defp state_to_byte(:off), do: 0x00
  defp state_to_byte(:unknown), do: :unknown

  defp state_from_byte(0x00), do: :off
  defp state_from_byte(0xFE), do: :unknown
  defp state_from_byte(int) when int in 0..99 when int == 0xFF, do: :on

  defimpl Inspect do
    def inspect(_value, _opts) do
      "#BasicReportValue<..>"
    end
  end
end
