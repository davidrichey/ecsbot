defmodule Ecsbot do
  use Application
  import Supervisor.Spec

  def start(_, _) do
    case Mix.env() do
      :test ->
        Task.start(fn -> :timer.sleep(0) end)

      _ ->
        # opts = [strategy: :one_for_one, name: Ecsbot.Supervisor]
        # children = [supervisor(Ecsbot.Supervisor.CheckSupervisor, [])]
        # Supervisor.start_link(children, opts)
        # Slack.Bot.start_link(Ecsbot.Slack, [], Application.get_env(:ecsbot, :slack_api_key))
        Task.start(fn -> :timer.sleep(0) end)
    end
  end

  def atomize_keys(map) do
    map |> Jason.encode!() |> Jason.decode!(keys: :atoms)
  end

  def aws(module), do: Application.get_env(:ecsbot, :aws)[module]

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
