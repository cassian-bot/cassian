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
      {:nostrum, git: "https://github.com/Kraigie/nostrum.git"},
      {:cowlib, "~> 2.9.1", override: true},
      {:plug_cowboy, "~> 2.4"},
      {:poison, "~> 4.0", override: true}
    ]
  end
end
