defmodule Ecsbot.Endpoint do
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason
  )

  plug(:dispatch)

  post "/command" do
    IO.inspect(conn.body_params)

    case conn.body_params do
      %{"key" => key, "command" => command} ->
        IO.inspect(valid(key))

        case valid(key) do
          :ok ->
            command(command, conn)

          _ ->
            send_resp(conn, 404, "Page not found")
        end

      _ ->
        send_resp(conn, 404, "Page not found")
    end
  end

  def command(text, conn) do
    txt = String.split(text, " ")
    # botname = Application.get_env(:ecsbot, :bot_name)

    # cond do
    #   Enum.at(txt, 0) == botname ->
    case Ecsbot.Command.command(Enum.at(txt, 1), txt, conn) do
      {:ok, _} ->
        conn |> send_resp(204, "")

      {:no_reploy, _} ->
        conn |> send_resp(204, "")

      {:error, msg} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(422, Jason.encode!(%{error: msg}))

      {:reply, msg, params} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(%{message: msg, params: params}))
    end

    #   true ->
    #     conn
    #     |> put_resp_content_type("application/json")
    #     |> send_resp(422, Jason.encode!(%{error: "Invalid bot name"}))
    # end
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
