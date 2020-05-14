defmodule Ecsbot do
  use Application
  import Supervisor.Spec

  def start(_, _) do
    opts = [strategy: :one_for_one, name: Ecsbot.Supervisor]

    case Application.get_env(:ecsbot, :slack_enabled) do
      "true" ->
        children = [
          Ecsbot.Endpoint,
          supervisor(Ecsbot.Supervisor.CheckSupervisor, [])
        ]

        Supervisor.start_link(children, opts)
        Slack.Bot.start_link(Ecsbot.Slack, [], Application.get_env(:ecsbot, :slack_api_key))

      _ ->
        Supervisor.start_link([Ecsbot.Endpoint], opts)
    end
  end

  def atomize_keys(map) do
    map |> Jason.encode!() |> Jason.decode!(keys: :atoms)
  end

  def aws(module), do: Application.get_env(:ecsbot, :aws)[module]

  def camel_map(map, all \\ [])

  def camel_map(nil, _), do: %{}

  def camel_map(map, _) when is_map(map) do
    Enum.into(map, []) |> camel_map([])
  end

  def camel_map([{key, v} | t], list) do
    <<head::binary-size(1)>> <> rest = Macro.camelize(key)
    camel_map(t, [{"#{String.downcase(head)}#{rest}", v} | list])
  end

  def camel_map([], list),
    do: Enum.into(list, %{}) |> atomize_keys()

  def snake_map(map, all \\ [])

  def snake_map(nil, _), do: %{}

  def snake_map(map, _) when is_map(map) do
    Enum.into(map, []) |> snake_map([])
  end

  def snake_map([{key, v} | t], list) do
    snake_map(t, [{Macro.underscore(key), v} | list])
  end

  def snake_map([], list),
    do: Enum.into(list, %{}) |> atomize_keys()
end
