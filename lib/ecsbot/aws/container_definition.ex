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

  def build(slack, configuration) do
    defaults = %Ecsbot.AWS.ContainerDefinition{}

    container_definition =
      struct(defaults, %{
        # list
        command: configuration[:command] || defaults.command,
        cpu: configuration[:cpu] || defaults.cpu,
        disable_networking: configuration[:disable_networking] || defaults.disable_networking,
        dns_search_domains: configuration[:dns_search_domains] || defaults.dns_search_domains,
        dns_servers: configuration[:dns_servers] || defaults.dns_servers,
        dockerlabels: configuration[:dockerlabels] || defaults.dockerlabels,
        docker_securityoptions:
          configuration[:docker_securityoptions] || defaults.docker_securityoptions,
        entry_point: configuration[:entry_point] || defaults.entry_point,
        environment: configuration[:environment] || defaults.environment,
        essential: configuration[:essential] || defaults.essential,
        extra_hosts: configuration[:extra_hosts] || defaults.extra_hosts,
        hostname: configuration[:hostname] || defaults.hostname,
        image: configuration[:image] || defaults.image,
        links: configuration[:links] || defaults.links,
        log_configuration: configuration[:log_configuration] || defaults.log_configuration,
        memory: configuration[:memory] || defaults.memory,
        mount_points: configuration[:mount_points] || defaults.mount_points,
        name: slack.service_name || defaults.name,
        port_mappings: configuration[:port_mappings] || defaults.port_mappings,
        privileged: configuration[:privileged] || defaults.privileged,
        readonly_root_filesystem:
          configuration[:readonly_root_filesystem] || defaults.readonly_root_filesystem,
        ulimits: configuration[:ulimits] || defaults.ulimits,
        user: configuration[:user] || defaults.user,
        volumes_from: configuration[:volumes_from] || defaults.volumes_from,
        working_directory: configuration[:working_directory] || defaults.working_directory
      })

    family = configuration.family

    {[container_definition], family}
  end
end
