Mox.defmock(Ecsbot.AWS.Configuration, for: Ecsbot.AWS.Configuration)
Mox.defmock(Ecsbot.AWS.Service, for: Ecsbot.AWS.Service)
Mox.defmock(Ecsbot.AWS.TaskDefinition, for: Ecsbot.AWS.TaskDefinition)
Mox.defmock(Ecsbot.Supervisor.CheckSupervisor, for: Ecsbot.Supervisor.CheckSupervisor)
ExUnit.start()

defmodule TestHelper do
  def json_from_file(file) do
    File.read!("#{File.cwd!()}/#{file}")
    |> Jason.decode!()
  end
end
