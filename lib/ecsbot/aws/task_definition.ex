defmodule Ecsbot.AWS.TaskDefinition do
  require Logger
  @derive Jason.Encoder
  defstruct(
    compatibilities: [],
    container_definitions: [],
    family: nil,
    placement_constraints: [],
    requires_attributes: [],
    revision: nil,
    status: nil,
    task_definition_arn: nil,
    volumes: nil
  )

  def register(container_definitions, family) do
    case ExAws.ECS.register_task_definition(family, container_definitions) |> ExAws.request() do
      {:ok, %{"taskDefinition" => task_definition}} ->
        task_definition = Ecsbot.snake_map(task_definition)
        {:ok, struct(%Ecsbot.AWS.TaskDefinition{}, task_definition)}

      {:error, {:http_error, status, %{body: body}}} ->
        Logger.warn("AWS Task Registration Error: #{body}")
        {:error, "AWS Task Registration Error: #{status}"}
    end
  end
end
