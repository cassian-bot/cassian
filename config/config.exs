use Mix.Config

config :porcelain,
  driver: Porcelain.Driver.Basic

config :nostrum,
  ffmpeg: System.get_env("FFMPEG_PATH") || "/usr/bin/ffmpeg",
  youtubedl: System.get_env("YTDL_PATH") || "/usr/bin/youtube-dl",
  token: System.get_env("DISCORD_BOT_TOKEN"),
  num_shards: :auto

config :cassian,
  prefix: System.get_env("DEFAULT_BOT_PREFIX"),
  web_enabled: System.get_env("WEB_ENABLED"),
  port: System.get_env("PORT") || "4000",
  force_ssl: System.get_env("FORCE_SSL"),
  sound_cloud_id: System.get_env("SOUND_CLOUD_ID")
