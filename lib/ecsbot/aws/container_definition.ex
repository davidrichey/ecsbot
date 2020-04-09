defmodule Ecsbot.AWS.ContainerDefinition do
  @derive Jason.Encoder
  defstruct(
    command: nil,
    cpu: nil,
    disableNetworking: nil,
    dnsSearchDomains: nil,
    dnsServers: nil,
    dockerLabels: nil,
    dockerSecurityOptions: nil,
    entryPoint: nil,
    environment: nil,
    essential: true,
    extraHosts: nil,
    hostname: nil,
    image: nil,
    links: [],
    logConfiguration: nil,
    memory: nil,
    mountPoints: [],
    name: nil,
    portMappings: nil,
    privileged: nil,
    readonlyRootFilesystem: nil,
    ulimits: nil,
    user: nil,
    volumesFrom: [],
    workingDirectory: nil
  )

  def build(
        %{
          "cpu" => cpu,
          "environmentVariables" => environment_variables,
          "family" => family,
          "image" => image,
          "memory" => memory,
          "name" => name,
          "tag" => tag
        } = opts
      ) do
    command = string_or_empty_array(opts["command"])
    entry_point = string_or_empty_array(opts["entryPoint"])
    port_mappings = opts["portMappings"] || []

    {[
       struct(%Ecsbot.AWS.ContainerDefinition{}, %{
         command: command,
         cpu: cpu,
         entryPoint: entry_point,
         environment: environment_variables,
         essential: true,
         image: "#{image}:#{tag}",
         memory: memory,
         name: name,
         portMappings: port_mappings
       })
     ], family}
  end

  defp string_or_empty_array(nil), do: []
  defp string_or_empty_array(list) when is_list(list), do: list
  defp string_or_empty_array(string), do: String.split(string, " ")
end
