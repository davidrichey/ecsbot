defmodule Ecsbot.CommandTest do
  use ExUnit.Case, async: true

  setup do
    %{
      command: %Ecsbot.Command{
        action: "describe",
        channel: :ok,
        cluster_name: "cluster",
        command: ["bot", "create", "service", "cluster", "service", "up"],
        configuration: %{
          cpu: 256,
          deploymentConfiguration: %{maximumPercent: 200, minimumHealthyPercent: 100},
          desiredCount: 1,
          environment: [%{name: "MIX_ENV", value: "prod"}],
          family: "integrations",
          image: "501288292052.dkr.ecr.us-east-1.amazonaws.com/eagle",
          memory: 300,
          portMappings: [%{containerPort: 4000, hostPort: 0, protocol: "tcp"}],
          protocol: "tcp"
        },
        object: "service",
        service_name: "service",
        slack: :ok
      }
    }
  end

  test "create service", %{command: command} do
    assert Ecsbot.Command.command(struct(command, %{action: "create"})) ==
             {:reply,
              "Created service for to `service` (`cluster`)\nDeployed `up` to `service` `cluster`\n> task `fake_task_definition_arn` service `fake_service_arn` tag `up`"}
  end

  test "deploy service", %{command: command} do
    assert Ecsbot.Command.command(struct(command, %{action: "deploy"})) ==
             {:reply,
              "Deployed `up` to `service` `cluster`\n> task `fake_task_definition_arn` service `fake_service_arn` tag `up`"}
  end

  test "describe service", %{command: command} do
    assert Ecsbot.Command.command(struct(command, %{action: "describe"})) ==
             {:reply,
              "> service (cluster)\n> Tasks running ` / `\n> Task    `task_arn`\n> Service `service`\n> Cluster `cluster`\n> AWS: https://console.aws.amazon.com/ecs/home?#/clusters/cluster/services/service/tasks"}
  end

  test "scale service", %{command: command} do
    assert Ecsbot.Command.command(struct(command, %{action: "scale"})) ==
             {:reply, "Scaled `service` to 2\n> service `fake_service_arn` cluster `cluster`"}
  end
end
