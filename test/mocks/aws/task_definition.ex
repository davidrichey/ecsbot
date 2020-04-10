defmodule Mocks.AWS.TaskDefinition do
  def register(container_definitions, family) do
    {:ok, %Ecsbot.AWS.TaskDefinition{task_definition_arn: "fake_task_definition_arn"}}
  end
end
