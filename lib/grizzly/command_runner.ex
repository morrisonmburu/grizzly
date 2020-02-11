defmodule Grizzly.CommandRunner do
  use GenServer

  alias Grizzly.CommandRunner.Command

  @type opt :: {:handler, module()}

  def start_link(opts) do
    opts = Keyword.put_new(opts, :waiter, self())
    GenServer.start_link(__MODULE__, opts)
  end

  def handle_ack(runner, seq_number) do
    GenServer.call(runner, {:handle_ack, seq_number})
  end

  def init(opts) do
    handler = Keyword.fetch!(opts, :handler)
    waiter = Keyword.fetch!(opts, :waiter)
    zip_packet = Keyword.fetch!(opts, :zip_packet)

    {:ok, handler_state} = handler.init()

    {:ok,
     %Command{
       handler: handler,
       waiter: waiter,
       zip_packet: zip_packet,
       handler_state: handler_state
     }}
  end

  def handle_call({:handle_ack, seq_number}, _from, command) do
    case Command.handle_ack_for_handler(command, seq_number) do
      {:send, response} ->
        GenServer.reply(command.waiter, response)
        {:reply, :ok, command}
    end
  end
end
