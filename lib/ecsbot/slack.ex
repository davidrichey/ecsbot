defmodule Ecsbot.Slack do
  use Slack
  require Logger

  def handle_connect(slack, state) do
    Logger.debug("Connected as #{slack.me.name}")
    {:ok, state}
  end

  @doc """
  Handles slack events
  Returns {:ok, _}
  """
  def handle_event(slack_message = %{type: "message", text: text}, slack, state) do
    txt = String.split(text, " ")
    botname = Application.get_env(:ecsbot, :bot_name)

    user_verified =
      case Application.get_env(:ecsbot, :users) do
        nil ->
          true

        users ->
          String.split(users, ",") |> Enum.member?(slack_message.user)
      end

    cond do
      Enum.at(txt, 0) == botname && user_verified ->
        try do
          case command(Enum.at(txt, 1), Enum.at(txt, 2), txt, slack, slack_message.channel) do
            {:ok, _} ->
              {:ok, state}

            {:no_reploy, _} ->
              {:ok, state}

            {:error, msg} ->
              send_message(":warning: #{msg}", slack_message.channel, slack)
              {:ok, msg}

            {:reply, msg, _} ->
              send_message(msg, slack_message.channel, slack)
              {:ok, msg}
          end
        rescue
          RuntimeError -> Logger.error("Error!")
        end

      true ->
        {:ok, state}
    end
  end

  def handle_event(_, _, state), do: {:ok, state}

  def command(action, "service", txt, slack, channel) do
    case Ecsbot.Configuration.fetch(Enum.at(txt, 3), Enum.at(txt, 4)) do
      {:ok, configuration} ->
        slack = %Ecsbot.Command{
          action: action,
          channel: channel,
          command: txt,
          configuration: configuration,
          cluster_name: Enum.at(txt, 3),
          object: "service",
          service_name: Enum.at(txt, 4),
          slack: slack
        }

        Ecsbot.Command.command(slack)

      {:error, error} ->
        {:error, error}
    end
  end

  def command(cmd, object, _, _, _) do
    {:error, "Unknown command `#{cmd}` for `#{object}`"}
  end
end
