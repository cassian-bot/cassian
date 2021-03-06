use Mix.Config

config :porcelain,
  driver: Porcelain.Driver.Basic

config :spoticord,
  token: System.get_env("TOKEN"),
  prefix: '$'