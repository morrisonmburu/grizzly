defmodule Grizzly.Transport.UDP do
  @behaviour Grizzly.Transport

  @test_host {0, 0, 0, 0}
  @test_port 5_000

  @impl true
  def open(_host, port) do
    case :gen_udp.open(port, [:binary, {:active, true}]) do
      {:ok, socket} -> {:ok, socket}
    end
  end

  @impl true
  def send(socket, binary) do
    :gen_udp.send(socket, @test_host, @test_port, binary)
  end

  @impl true
  def parse_response({:udp, _, _, _, binary}) do
    {:ok, binary}
  end

  @impl true
  def close(socket) do
    :gen_udp.close(socket)
  end
end
