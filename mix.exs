defmodule Cassian.MixProject do
  use Mix.Project

  def project do
    [
      app: :cassian,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Cassian.Application, []},
      extra_applications: [:logger, :plug_cowboy]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, github: "Kraigie/nostrum"},
      {:poison, "~> 5.0"},
      {:httpoison, "~> 2.0"},
      {:cowlib, "~> 2.9.1", override: true},
      {:plug_cowboy, "~> 2.4"},
      {:floki, "~> 0.31.0"}
    ]
  end
end
