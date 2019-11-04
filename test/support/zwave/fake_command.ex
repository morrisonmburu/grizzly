defmodule ZWave.Test.FakeCommand do
  use ZWave.Command

  defcommand :fake_command do
    command_byte(0x01)
    command_class(__MODULE__)
  end
end
