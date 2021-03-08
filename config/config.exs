use Mix.Config
config :porcelain,
  driver: Porcelain.Driver.Basic

config :nostrum,
  ffmpeg: "/usr/bin/ffmpeg",
  youtubedl: "/usr/local/bin/youtube-dl",
  token: System.get_env("DISCORD_BOT_TOKEN"),
  num_shards: :auto

config :artificer,
  prefix: System.get_env("DEFAULT_BOT_PREFIX")
