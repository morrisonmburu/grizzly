defmodule Grizzly.CommandHandler do
  @callback init() :: {:ok, state :: any()}

  @callback handle_ack(state :: any()) :: :complete | {:continue, state :: any()}

  @callback handle_command(ZWaveCommand.t(), state :: any()) ::
              :complete | {:continue, state :: any()}

  @optional_callbacks handle_command: 2
end
