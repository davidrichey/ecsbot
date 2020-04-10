defmodule Mocks.AWS.Service do
  def create(%Ecsbot.AWS.Service{desired_count: desired_count}) do
    {:ok, %Ecsbot.AWS.Service{desired_count: desired_count, service_arn: "fake_service_arn"}}
  end

  def update(%Ecsbot.AWS.Service{desired_count: desired_count}) do
    {:ok, %Ecsbot.AWS.Service{desired_count: desired_count, service_arn: "fake_service_arn"}}
  end

  def describe(_cluster, service) do
    # TODO: add mock from actual
    {:ok,
     %Ecsbot.AWS.Service{
       deployments: [%{taskDefinition: "task_arn"}],
       task_definition: "task_arn",
       service_name: service
     }}
  end
end
