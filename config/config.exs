use Mix.Config
config :porcelain,
  driver: Procelain.Driver.Basic

config :nostrum,
  token: System.get_env("TOKEN"),
  num_shards: :auto

config :spoticord,
  prefix: '$'
