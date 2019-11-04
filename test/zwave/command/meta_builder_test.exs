defmodule ZWave.Command.MetaBuilderTest do
  use ExUnit.Case, async: true

  alias ZWave.Command.{MetaBuilder, Meta}

  test "create new empty meta builder" do
    assert %MetaBuilder{} == MetaBuilder.new()
  end

  describe "puts valid meta information" do
    test "source" do
      meta = MetaBuilder.new()
      expected_meta = %{meta | source: __MODULE__}

      assert {:ok, expected_meta} == MetaBuilder.put(meta, :source, __MODULE__)
    end

    test "name" do
      meta = MetaBuilder.new()
      expected_meta = %{meta | name: :meta_builder_test}

      assert {:ok, expected_meta} == MetaBuilder.put(meta, :name, expected_meta.name)
    end

    test "command class" do
      meta = MetaBuilder.new()
      expected_meta = %{meta | command_class: __MODULE__}

      assert {:ok, expected_meta} ==
               MetaBuilder.put(meta, :command_class, expected_meta.command_class)
    end

    test "command byte" do
      meta = MetaBuilder.new()
      expected_meta = %{meta | command_byte: 0xFF}

      assert {:ok, expected_meta} ==
               MetaBuilder.put(meta, :command_byte, expected_meta.command_byte)
    end
  end

  test "rejects an invalid meta field" do
    meta = MetaBuilder.new()

    assert {:error, :invalid_meta_field} == MetaBuilder.put(meta, :hello, :world)
  end

  describe "building a meta from a meta builder" do
    test "when all is okay" do
      opts = [
        command_class: __MODULE__,
        command_byte: 0xFF,
        source: __MODULE__,
        name: :meta_builder_test
      ]

      meta_builder =
        Enum.reduce(opts, MetaBuilder.new(), fn {field, value}, mb ->
          {:ok, new_meta_builder} = MetaBuilder.put(mb, field, value)
          new_meta_builder
        end)

      expected_meta = struct(Meta, opts)

      assert {:ok, expected_meta} == MetaBuilder.build(meta_builder)
    end

    test "when a field is nil" do
      opts = [
        command_class: __MODULE__,
        command_byte: nil,
        source: __MODULE__,
        name: :meta_builder_test
      ]

      meta_builder =
        Enum.reduce(opts, MetaBuilder.new(), fn {field, value}, mb ->
          {:ok, new_meta_builder} = MetaBuilder.put(mb, field, value)
          new_meta_builder
        end)

      assert {:error, [command_byte: nil]} == MetaBuilder.build(meta_builder)
    end

    test "when a field does not match the expected type" do
      opts = [
        command_class: __MODULE__,
        command_byte: :blue,
        source: __MODULE__,
        name: :meta_builder_test
      ]

      meta_builder =
        Enum.reduce(opts, MetaBuilder.new(), fn {field, value}, mb ->
          {:ok, new_meta_builder} = MetaBuilder.put(mb, field, value)
          new_meta_builder
        end)

      assert {:error, [command_byte: :blue]} == MetaBuilder.build(meta_builder)
    end
  end
end
