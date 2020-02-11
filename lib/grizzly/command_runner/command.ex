defmodule Grizzly.CommandRunner.Command do
  @enforce_keys [:handler, :waiter, :zip_packet]
  defstruct handler: nil, waiter: nil, zip_packet: nil, handler_state: nil, status: :waiting_ack

  def handle_ack_for_handler(command, seq_number) do
    if command.zip_packet.seq_number == seq_number do
      do_handle_ack_for_handler(command)
    else
      {:continue, command}
    end
  end

  defp do_handle_ack_for_handler(command) do
    case command.handler.handle_ack(command.handler_state) do
      :complete -> {:send, :ok}
    end
  end
end
