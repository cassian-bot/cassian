use Mix.Config
config :porcelain,
  driver: Procelain.Driver.Basic

config :nostrum,
  ffmpeg: "/usr/bin/ffmpeg",
  token: System.get_env("DISCORD_BOT_TOKEN"),
  num_shards: :auto

config :spoticord,
  prefix: System.get_env("DEFAULT_BOT_PREFIX")
