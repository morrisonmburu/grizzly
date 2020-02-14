defmodule GrizzlyTest.InitWaiter do
  alias Grizzly.Events

  def start() do
    :ok = Events.subscribe(:controller_connected)

    receive do
      {__MODULE__, :controller_connected} ->
        :ok
    end
  end
end
