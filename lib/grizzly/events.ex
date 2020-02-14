defmodule Grizzly.Events do
  @moduledoc """
  Module for working with events within the Grizzly run time.
  """
  @registry __MODULE__.Registry

  @type event :: :controller_connected

  @spec subscribe(event()) :: :ok
  def subscribe(event) do
    _ = Registry.register(@registry, event, [])
    :ok
  end

  @spec subscribe_all([event()]) :: :ok
  def subscribe_all(events) do
    Enum.each(events, &subscribe/1)
  end

  @spec unsubscribe(event()) :: :ok
  def unsubscribe(event) do
    Registry.unregister(@registry, event)
  end

  @spec broadcast(event()) :: :ok
  def broadcast(event) do
    Registry.dispatch(@registry, event, fn listeners ->
      for {pid, _} <- listeners, do: send(pid, {__MODULE__, event})
    end)
  end

  @spec broadcast(event(), any()) :: :ok
  def broadcast(event, event_data) do
    Registry.dispatch(@registry, event, fn listeners ->
      for {pid, _} <- listeners, do: send(pid, {__MODULE__, event, event_data})
    end)
  end
end
