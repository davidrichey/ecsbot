defmodule Ecsbot.Configuration do
  require Logger

  def fetch(cluster_name, service_name) do
    bucket = Application.get_env(:ecsbot, :aws_bucket)

    case ExAws.S3.get_object(bucket, "#{service_name}/#{cluster_name}.json") |> ExAws.request() do
      {:ok, %{body: body}} ->
        case Jason.decode(body, keys: :atoms) do
          {:ok, json} ->
            {:ok, json}

          _ ->
            Logger.warn("AWS Configuration JSON parsing error: #{body}")
            {:error, "AWS Configuration JSON parsing error"}
        end

      {:error, {:http_error, status, %{body: body}}} ->
        Logger.warn("AWS Configuration Error: #{body}")
        {:error, "AWS Configuration Error: #{status}"}
    end
  end

  # def fetch(_, _) do
  #   {:ok,
  #    %{
  #      cpu: 256,
  #      family: "integrations",
  #      image: "501288292052.dkr.ecr.us-east-1.amazonaws.com/eagle",
  #      memory: 300,
  #      protocol: "tcp",
  #      portMappings: [
  #        %{
  #          hostPort: 0,
  #          containerPort: 4000,
  #          protocol: "tcp"
  #        }
  #      ],
  #      environment: [
  #        %{name: "MIX_ENV", value: "prod"}
  #      ],
  #      deploymentConfiguration: %{
  #        maximumPercent: 200,
  #        minimumHealthyPercent: 100
  #      },
  #      desiredCount: 1
  #    }}
  # end
end
