defmodule Ecsbot.AWS.ContainerDefinitionTest do
  use ExUnit.Case, async: true

  test "builds struct with defaults" do
    {[definition], family} =
      Ecsbot.AWS.ContainerDefinition.build(
        %{service_name: "name"},
        %{
          command: ["command"],
          cpu: "cpu",
          environmentVariables: %{},
          family: "family",
          image: "image",
          memory: "memory",
          name: "name",
          tag: "tag"
        }
      )

    # string turned to list
    assert definition.command == ["command"]
    # was nil, turned to empty list
    assert definition.port_mappings == []

    assert family == "family"
  end
end
