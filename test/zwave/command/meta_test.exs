defmodule ZWave.Command.MetaTest do
  use ExUnit.Case, async: true

  alias ZWave.Command.Meta

  setup do
    opts = [command_class: __MODULE__, command_byte: 0xFF, name: :meta_test, source: __MODULE__]
    meta = struct(Meta, opts)

    {:ok, meta: meta}
  end

  test "access the source field", %{meta: meta} do
    assert __MODULE__ == Meta.source(meta)
  end

  test "access the command_class field", %{meta: meta} do
    assert __MODULE__ == Meta.command_class(meta)
  end

  test "access the command_byte field", %{meta: meta} do
    assert 0xFF == Meta.command_byte(meta)
  end

  test "access the name field", %{meta: meta} do
    assert :meta_test == Meta.name(meta)
  end
end
