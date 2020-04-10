defmodule Ecsbot.Slack.Service do
  @doc """
  Handles slack ECS service creation
  botname create service environment appname version
  Returns {:ok, _}
  """
  def command(slack = %Ecsbot.Slack{action: "create", object: "service"}) do
    tag = Enum.at(slack.command, 5)

    configuration = slack.configuration || %{}

    service =
      struct(%Ecsbot.AWS.Service{}, %{
        cluster_name: slack.cluster_name,
        deployment_configuration: configuration.deploymentConfiguration,
        desired_count: configuration.desiredCount,
        service_name: slack.service_name
      })

    {container_definitions, family} =
      Ecsbot.AWS.ContainerDefinition.build(slack, slack.configuration)

    Ecsbot.aws(:task_definition).register(container_definitions, family)

    case Ecsbot.aws(:task_definition).register(container_definitions, family) do
      {:ok, %Ecsbot.AWS.TaskDefinition{task_definition_arn: task_definition_arn}} ->
        case Ecsbot.aws(:service).create(struct(service, %{task_definition: task_definition_arn})) do
          {:ok, %Ecsbot.AWS.Service{service_arn: service_arn}} ->
            :ok

            {:reply,
             "Created service for to `#{service.service_name}` (`#{service.cluster_name}`)\n" <>
               "Deployed `#{tag}` to `#{service.service_name}` `#{service.cluster_name}`\n" <>
               "> task `#{task_definition_arn}` service `#{service_arn}` tag `#{tag}`"}

          {:error, msg} ->
            {:error, msg}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  # @doc """
  # Handles slack deploys
  # botname deploy cluster_name service_name tag
  # Returns {:ok, _}
  def command(
        slack = %Ecsbot.Slack{
          action: "deploy",
          command: command,
          cluster_name: cluster_name,
          service_name: service_name,
          object: "service"
        }
      ) do
    tag = Enum.at(command, 5)

    case Ecsbot.aws(:service).describe(cluster_name, service_name) do
      {:ok, service} ->
        configuration = slack.configuration || %{}

        {container_definitions, family} =
          Ecsbot.AWS.ContainerDefinition.build(slack, configuration)

        case Ecsbot.aws(:task_definition).register(container_definitions, family) do
          {:ok, %Ecsbot.AWS.TaskDefinition{task_definition_arn: task_definition_arn}} ->
            case Ecsbot.aws(:service).update(
                   struct(service, %{task_definition: task_definition_arn})
                 ) do
              {:ok, %Ecsbot.AWS.Service{service_arn: service_arn}} ->
                # TODO:
                # Ecsbot.Supervisor.CheckSupervisor.enqueue({
                #   service,
                #   cluster,
                #   task,
                #   channel,
                #   slack,
                #   1
                # })

                {:reply,
                 "Deployed `#{tag}` to `#{service.service_name}` `#{cluster_name}`\n" <>
                   "> task `#{task_definition_arn}` service `#{service_arn}` tag `#{tag}`"}

              {:error, msg} ->
                {:error, msg}
            end

          {:error, error} ->
            {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Handles slack scaling events
  botname describe environment appname
  Returns {:ok, _}
  """
  def command(%Ecsbot.Slack{
        action: "describe",
        object: "service",
        cluster_name: cluster_name,
        service_name: service_name
      }) do
    case Ecsbot.aws(:service).describe(cluster_name, service_name) do
      {:ok, service} ->
        [deployment | _] = service.deployments

        msg =
          "> #{service_name} (#{cluster_name})\n" <>
            "> Tasks running `#{deployment[:runningCount]} / #{deployment[:desiredCount]}`\n" <>
            "> Task    `#{service.task_definition}`\n" <>
            "> Service `#{service.service_name}`\n" <>
            "> Cluster `#{cluster_name}`\n" <>
            "> AWS: https://console.aws.amazon.com/ecs/home?" <>
            "#/clusters/#{cluster_name}/services/#{service.service_name}/tasks"

        {:reply, msg}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Handles slack scaling events
  botname scale environment appname desired_count
  Returns {:ok, _}
  """
  def command(%Ecsbot.Slack{
        action: "scale",
        object: "service",
        command: command,
        cluster_name: cluster_name,
        service_name: service_name
      }) do
    case Ecsbot.aws(:service).describe(cluster_name, service_name) do
      {:ok, service} ->
        desired_count =
          case Enum.at(command, 5) do
            "up" ->
              service.desired_count + 1

            "down" ->
              service.desired_count - 1

            count ->
              String.to_integer(count)
          end

        service = struct(service, %{desired_count: desired_count})

        case Ecsbot.aws(:service).update(service) do
          {:ok, service} ->
            msg =
              "Scaled `#{service_name}` to #{service.desired_count}\n" <>
                "> service `#{service.service_arn}` cluster `#{cluster_name}`"

            {:reply, msg}

          {:error, msg} ->
            {:error, msg}
        end

      {:error, msg} ->
        {:error, msg}
    end
  end
end
