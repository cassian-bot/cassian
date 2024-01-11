import Config

config :nostrum,
  ffmpeg: "/usr/bin/ffmpeg",
  youtubedl: "/usr/bin/youtube-dl",
  token: System.fetch_env!("DISCORD_BOT_TOKEN"),
  num_shards: :auto

config :cassian,
  web_enabled: System.fetch_env!("WEB_ENABLED"),
  port: "4000",
  force_ssl: System.fetch_env!("FORCE_SSL")
