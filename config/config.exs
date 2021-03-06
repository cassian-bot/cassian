use Mix.Config

config :nostrum,
  token: System.get_env("TOKEN"),
  num_shards: :auto

config :spoticord,
  prefix: '$'