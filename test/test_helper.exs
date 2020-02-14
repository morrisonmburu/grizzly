{:ok, _pid} = GrizzlyTest.Server.start(5000)

GrizzlyTest.InitWaiter.start()

ExUnit.start()
