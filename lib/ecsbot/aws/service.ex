defmodule Ecsbot.AWS.Service do
  require Logger

  @derive Jason.Encoder
  defstruct(
    cluster: nil,
    cluster_name: nil,
    cluster_arn: nil,
    created_at: nil,
    deployment_configuration: %{
      maximum_percent: 200,
      minimum_healthy_percent: 100
    },
    deployments: [],
    desired_count: 1,
    # events: [ ],
    # load_balancers: [ ],
    pending_count: 0,
    running_count: 0,
    service_arn: nil,
    service_name: nil,
    status: nil,
    task_definition: nil
  )

  @doc """
  Creates AWS ECS Service & within initial task
  Returns {:ok, Ecsbot.AWS.Service}
  """
  def create(service) do
    case ExAws.ECS.create_service(
           service.service_name,
           service.task_definition,
           service.desired_count,
           service |> Jason.encode!() |> Jason.decode!() |> Ecsbot.camel_map()
         )
         |> ExAws.request() do
      {:ok, %{"service" => service}} ->
        service = Ecsbot.snake_map(service)
        {:ok, struct(%Ecsbot.AWS.Service{}, service)}

      {:error, {:http_error, status, %{body: body}}} ->
        Logger.warn("AWS Service Create Error: #{body}")
        {:error, "AWS Service Create Error: #{status}"}
    end
  end

  @doc """
  Updates AWS ECS Service
  Returns {:ok, Ecsbot.AWS.Service}
  """
  def update(service) do
    case ExAws.ECS.update_service(
           service.service_name,
           service |> Jason.encode!() |> Jason.decode!() |> Ecsbot.camel_map()
         )
         |> ExAws.request() do
      {:ok, %{"service" => service}} ->
        service = Ecsbot.snake_map(service)
        {:ok, struct(%Ecsbot.AWS.Service{}, service)}

      {:error, {:http_error, status, %{body: body}}} ->
        Logger.warn("AWS Service Update Error: #{body}")
        {:error, "AWS Service Update Error: #{status}"}
    end
  end

  @doc """
  Describes AWS ECS Service
  Returns {:ok, Ecsbot.AWS.Service}
  """
  def describe(cluster, service) do
    case ExAws.ECS.describe_services([service], %{"cluster" => cluster})
         |> ExAws.request() do
      {:ok, %{"services" => services}} ->
        service = services |> Enum.at(0)
        service = Ecsbot.snake_map(service)
        {:ok, struct(%Ecsbot.AWS.Service{cluster: cluster}, service)}

      {:error, {:http_error, status, %{body: body}}} ->
        Logger.warn("AWS Service Describe Error: #{body}")
        {:error, "AWS Service Describe Error: #{status}"}
    end
  end
end
