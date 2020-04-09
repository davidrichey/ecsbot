defmodule Ecsbot.AWS.ConfigurationTest do
  use ExUnit.Case, async: true
  import Mox

  test "calls AWS S3" do
    Ecsbot.ExAwsMock
    |> expect(:request, fn -> {:ok, %{body: "{\"test\": 123}"}} end)

    Ecsbot.AWS.Configuration.fetch("bucket", "name", "env")
  end
end
