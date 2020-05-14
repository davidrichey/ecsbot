defmodule Ecsbot.Endpoint do
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason
  )

  plug(:dispatch)

  post "/command" do
    case conn.body_params do
      %{"key" => key, "command" => command} ->
        case valid(key) do
          :ok ->
            txt = String.split(command, " ")

            case command(Enum.at(txt, 1), Enum.at(txt, 2), txt, conn) do
              {:ok, _} ->
                conn |> send_resp(204, "")

              {:no_reploy, _} ->
                conn |> send_resp(204, "")

              {:error, msg} ->
                conn
                |> put_resp_content_type("application/json")
                |> send_resp(422, Jason.encode!(%{error: msg}))

              {:reply, msg} ->
                conn
                |> put_resp_content_type("application/json")
                |> send_resp(200, Jason.encode!(%{message: msg}))
            end

          _ ->
            send_resp(conn, 404, "Page not found")
        end

      _ ->
        send_resp(conn, 404, "Page not found")
    end
  end

  def command(action, "service", txt, conn) do
    case Ecsbot.Configuration.fetch(Enum.at(txt, 3), Enum.at(txt, 4)) do
      {:ok, configuration} ->
        command = %Ecsbot.Command{
          action: action,
          command: txt,
          conn: conn,
          configuration: configuration,
          cluster_name: Enum.at(txt, 3),
          object: "service",
          service_name: Enum.at(txt, 4)
        }

        Ecsbot.Command.command(command)

      {:error, error} ->
        {:error, error}
    end
  end

  def valid(key) do
    apikey = Application.get_env(:ecsbot, :web_api_key)

    case {apikey, key === apikey} do
      {nil, _} -> :ok
      {_, true} -> :ok
      _ -> {:error, "Page not found"}
    end
  end

  match _ do
    send_resp(conn, 404, "Page not found")
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts),
    do: Plug.Cowboy.http(__MODULE__, [])
end
