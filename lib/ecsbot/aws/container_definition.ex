defmodule Ecsbot.AWS.ContainerDefinition do
  @derive Jason.Encoder
  defstruct(
    command: [],
    cpu: 256,
    disable_networking: nil,
    dns_search_domains: nil,
    dns_servers: nil,
    dockerlabels: nil,
    docker_securityoptions: nil,
    entry_point: [],
    # [ %{name: "ONE", value: "ONE"}, %{name: "TWO", value: "TWO"} ]
    environment: [],
    essential: true,
    extra_hosts: nil,
    hostname: nil,
    image: nil,
    links: [],
    log_configuration: nil,
    memory: 300,
    mount_points: [],
    name: nil,
    # [ %{containerPort: 0, hostPort: 4000, protocol: "tcp"} ]
    port_mappings: [],
    privileged: nil,
    readonly_root_filesystem: nil,
    ulimits: nil,
    user: nil,
    volumes_from: [],
    working_directory: nil
  )

  def build(slack, configuration, tag) do
    defaults = %Ecsbot.AWS.ContainerDefinition{}

    container_definition =
      struct(defaults, %{
        # list
        command: configuration[:command] || defaults.command,
        cpu: configuration[:cpu] || defaults.cpu,
        disable_networking: configuration[:disableNetworking] || defaults.disable_networking,
        dns_search_domains: configuration[:dnsSearchDomains] || defaults.dns_search_domains,
        dns_servers: configuration[:dnsServers] || defaults.dns_servers,
        dockerlabels: configuration[:dockerlabels] || defaults.dockerlabels,
        docker_securityoptions:
          configuration[:dockerSecurityoptions] || defaults.docker_securityoptions,
        entry_point: configuration[:entryPoint] || defaults.entry_point,
        environment:
          configuration[:environment] || configuration[:environmentVariables] ||
            defaults.environment,
        essential: configuration[:essential] || defaults.essential,
        extra_hosts: configuration[:extraHosts] || defaults.extra_hosts,
        hostname: configuration[:hostname] || defaults.hostname,
        image: "#{configuration[:image] || defaults.image}:#{tag}",
        links: configuration[:links] || defaults.links,
        log_configuration: configuration[:logConfiguration] || defaults.log_configuration,
        memory: configuration[:memory] || defaults.memory,
        mount_points: configuration[:mountPoints] || defaults.mount_points,
        name: slack.service_name || defaults.name,
        port_mappings: configuration[:portMappings] || defaults.port_mappings,
        privileged: configuration[:privileged] || defaults.privileged,
        readonly_root_filesystem:
          configuration[:readonlyRootFilesystem] || defaults.readonly_root_filesystem,
        ulimits: configuration[:ulimits] || defaults.ulimits,
        user: configuration[:user] || defaults.user,
        volumes_from: configuration[:volumesFrom] || defaults.volumes_from,
        working_directory: configuration[:workingDirectory] || defaults.working_directory
      })

    family = configuration.family

    {[container_definition], family}
  end
end
