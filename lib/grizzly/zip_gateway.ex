defmodule Grizzly.ZIPGateway do
  @moduledoc false

  @default_port 41230

  @spec host_for_node(non_neg_integer()) :: :inet.ip_address()
  def host_for_node(node_id), do: {0xFD00, 0xAAAA, 0, 0, 0, 0, 0, node_id}

  @spec port() :: :inet.port_number()
  def port() do
    case Application.get_env(:grizzly, :zip_gateway) do
      nil ->
        @default_port

      zip_gateway_config ->
        zip_gateway_config.port || @default_port
    end
  end
end
