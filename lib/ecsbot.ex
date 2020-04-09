defmodule Ecsbot do
  use Application
  import Supervisor.Spec

  def start(_, _) do
    case Mix.env() do
      :test ->
        Task.start(fn -> :timer.sleep(0) end)

      _ ->
        opts = [strategy: :one_for_one, name: Ecsbot.Supervisor]
        children = [supervisor(Ecsbot.Supervisor.CheckSupervisor, [])]
        Supervisor.start_link(children, opts)
        Slack.Bot.start_link(Ecsbot.Slack, [], Application.get_env(:ecsbot, :slack_api_key))
    end
  end
end
