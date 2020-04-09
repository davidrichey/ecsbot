defmodule Ecsbot.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecsbot,
      version: "0.0.1",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Ecsbot, []},
      extra_applications: [:mix, :logger, :slack, :timber]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:distillery, "~> 2.0"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_ecs, "~> 0.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.15"},
      # TODO: Try to upgrade slack
      {:slack, "~> 0.15.0"},
      {:sweet_xml, "~> 0.6"},
      # TODO: Evaluate if this should be in
      {:timber, "~> 2.5"},
      {:httpoison, "~> 1.3"},
      {:jason, "~> 1.2"},
      {:mox, "~> 0.4", only: :test}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
