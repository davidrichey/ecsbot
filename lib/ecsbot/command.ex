defmodule Ecsbot.Command do
  require Logger

  def command(c, txt, requestor, name \\ "")

  @doc """
  Handles requestor deploys
  botname deploy environment appname version
  Returns {:ok, _}
  """
  def command("deploy", txt, _requestor, _name) do
    environment = Enum.at(txt, 2)
    name = Enum.at(txt, 3)
    tag = Enum.at(txt, 4)

    case Ecsbot.AWS.Configuration.fetch(
           Application.get_env(:ecsbot, :aws_bucket),
           name,
           environment
         ) do
      {:ok, aws_config} ->
        {cds, family} =
          Ecsbot.AWS.ContainerDefinition.build(%{"tag" => tag} |> Map.merge(aws_config))

        case Ecsbot.AWS.TaskDefinition.register(cds, family) do
          {:ok, task} ->
            service_opts = aws_config |> Map.merge(%{"taskDefinition" => task})

            case Ecsbot.AWS.Service.update(service_opts) do
              {:ok, {_, arn}} ->
                msg =
                  "Deployed #{tag} to #{name} #{environment}\n" <>
                    "> task `#{task}` service `#{arn}`"

                # Enqueue Check working
                # %{"cluster" => cluster, "service" => service} = service_opts
                #
                # Ecsbot.Supervisor.CheckSupervisor.enqueue({
                #   service,
                #   cluster,
                #   task,
                #   name,
                #   requestor,
                #   1
                # })

                {:reply, msg,
                 %{tag: tag, name: name, environment: environment, task: task, arn: arn}}

              {:error, msg} ->
                {:error, msg}
            end

          {:error, msg} ->
            {:error, msg}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Handles requestor scaling events
  botname scale environment appname desired_count
  Returns {:ok, _}
  """
  def command("scale", txt, _channel, _slack) do
    environment = Enum.at(txt, 2)
    name = Enum.at(txt, 3)

    case Ecsbot.AWS.Configuration.fetch(
           Application.get_env(:ecsbot, :aws_bucket),
           name,
           environment
         ) do
      {:ok, aws_config} ->
        %{"cluster" => cluster, "service" => service} = aws_config

        desired_count =
          case Enum.at(txt, 4) do
            "up" ->
              case Ecsbot.AWS.Service.describe(service, cluster) do
                {:ok, %{"desiredCount" => count}} -> {:ok, count + 1}
                {:error, msg} -> {:error, msg}
              end

            "down" ->
              case Ecsbot.AWS.Service.describe(service, cluster) do
                {:ok, %{"desiredCount" => count}} -> {:ok, count - 1}
                {:error, msg} -> {:error, msg}
              end

            count ->
              {:ok, String.to_integer(count)}
          end

        case desired_count do
          {:ok, desired_count} ->
            service_opts = aws_config |> Map.merge(%{"desiredCount" => desired_count})

            case Ecsbot.AWS.Service.update(service_opts) do
              {:ok, {desired_count, arn}} ->
                msg =
                  "Scaled #{name} `#{environment}` to #{desired_count}\n" <> "> service `#{arn}`"

                {:reply, msg,
                 %{name: name, environment: environment, desired_count: desired_count, arn: arn}}

              {:error, msg} ->
                {:error, msg}
            end

          {:error, msg} ->
            {:error, msg}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Handles requestor scaling events
  botname describe environment appname
  Returns {:ok, _}
  """
  def command("describe", txt, _channel, _slack) do
    environment = Enum.at(txt, 2)
    name = Enum.at(txt, 3)

    case Ecsbot.AWS.Configuration.fetch(
           Application.get_env(:ecsbot, :aws_bucket),
           name,
           environment
         ) do
      {:ok, %{"cluster" => cluster, "service" => service}} ->
        case Ecsbot.AWS.Service.describe(service, cluster) do
          {:ok,
           %{
             "deployments" => deployments,
             "taskDefinition" => td,
             "serviceName" => service_name
           }} ->
            deployment =
              Enum.find(deployments, fn d ->
                d["taskDefinition"] == td
              end)

            case deployment do
              nil ->
                {:error, ":warning: No deployment found for #{td}"}

              _ ->
                msg =
                  ">#{name} (#{environment})\n" <>
                    "> Tasks running `#{deployment["runningCount"]} / #{
                      deployment["desiredCount"]
                    }`\n" <>
                    ">Task      `#{td}`\n>Service `#{service_name}`\n>Cluster `#{cluster}`\n" <>
                    "> AWS: https://console.aws.amazon.com/ecs/home?" <>
                    "#/clusters/#{cluster}/services/#{service}/tasks"

                {:reply, msg,
                 %{
                   name: name,
                   environment: environment,
                   task_definitiond: td,
                   service_name: service_name,
                   cluster: cluster,
                   service: service,
                   runningCount: deployment["runningCount"],
                   desiredCount: deployment["desiredCount"]
                 }}
            end

          {:error, msg} ->
            {:error, msg}
        end

      {:error, msg} ->
        {:error, msg}
    end
  end

  @doc """
  Handles requestor ECS service creation
  botname create-service environment appname version
  Returns {:ok, _}
  """
  def command("create-service", txt, _requestor, _name) do
    environment = Enum.at(txt, 2)
    name = Enum.at(txt, 3)
    tag = Enum.at(txt, 4)

    case Ecsbot.AWS.Configuration.fetch(
           Application.get_env(:ecsbot, :aws_bucket),
           name,
           environment
         ) do
      {:ok, aws_config} ->
        {cds, family} =
          Ecsbot.AWS.ContainerDefinition.build(%{"tag" => tag} |> Map.merge(aws_config))

        case Ecsbot.AWS.TaskDefinition.register(cds, family) do
          {:ok, task} ->
            service_opts = aws_config |> Map.merge(%{"taskDefinition" => task})

            case Ecsbot.AWS.Service.create(service_opts) do
              {:ok, {_, arn}} ->
                msg =
                  "Created service for to #{name} (#{environment})\n" <>
                    "Deployed #{tag} to #{name} #{environment}\n" <>
                    "> task `#{task}` service `#{arn}`"

                # Enqueue Check working
                # %{"cluster" => cluster, "service" => service} = service_opts
                #
                # Ecsbot.Supervisor.CheckSupervisor.enqueue({
                #   service,
                #   cluster,
                #   task,
                #   name,
                #   requestor,
                #   1
                # })

                {:reply, msg,
                 %{
                   name: name,
                   environment: environment,
                   tag: tag,
                   task: task,
                   arn: arn
                 }}

              {:error, msg} ->
                {:error, msg}
            end

          {:error, msg} ->
            {:error, msg}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  def command(cmd, _, _, _) do
    {:error, "Unknown command `#{cmd}`"}
  end
end
