defmodule Grizzly.Commands.DefaultSet do
  @behaviour Grizzly.CommandHandler

  @impl true
  def init() do
    {:ok, nil}
  end

  @impl true
  def handle_ack(_), do: :complete
end
