defmodule Artificer.Utils do
  @moduledoc """
  Module for general utils...
  """
  alias Nostrum.Cache.{GuildCache}
  alias Nostrum.Struct.Embed
  alias Nostrum.Api

  import Embed

  alias Artificer.Structs.VoicePermissions

  @doc """
  Add a color on an embed. The `color` params ia a hex string value of the color.
  It will be automaically converted to something Discord can use.
  """
  @spec put_color_on_embed(embed :: Embed, color :: String.t()) :: Embed
  def put_color_on_embed(embed, color \\ "#6699ff") do
    {color, _} =
      color
      |> String.replace_leading("#", "")
      |> Integer.parse(16)

    put_color(embed, color)
  end

  def put_error_color_on_embed(embed) do
    put_color(embed, 16711731)
  end

  @doc """
  Create an empty embed. It has the default color of the bot.
  """
  @spec create_empty_embed!() :: Embed
  def create_empty_embed!() do
    %Nostrum.Struct.Embed{}
    |> put_color_on_embed()
  end

  @doc """
  Get the user avatar url.
  """
  @spec user_avatar(user :: Nostrum.Struct.User) :: String.t()
  def user_avatar(user) do
    "https://cdn.discordapp.com/avatars/#{user.id}/#{user.avatar}.png"
  end

  @doc """
  Safely the current voice id in which the user is. Also returns the guild id.
  """
  @spec get_sender_voice_id(message :: Nostrum.Struct.Channel) :: {:ok, {guild_id :: String.t(), channel_id :: String.t()}} | {:error, :noop}
  def get_sender_voice_id(message) do
    voice_id =
      GuildCache.get!(message.guild_id)
      |> Map.fetch!(:voice_states)
      |> Enum.filter(fn state -> state.user_id == message.author.id end)
      |> List.first()
      |> extract_id()

    if voice_id do
      {:ok, {message.guild_id, voice_id}}
    else
      {:error, :noop}
    end
  end

  defp extract_id(channel) do
    channel[:channel_id]
  end

  @doc """
  Join or switch from the voice channel. Set the channel to nil to
  leave it.
  """
  @spec join_or_switch_voice(guild_id :: Snowflake.t(), channel_id :: Snowflake.t()) :: :ok
  def join_or_switch_voice(guild_id, channel_id) do
    guild_id
    |> Api.update_voice_state(channel_id, false, true)
  end

  @doc """
  Leave the voice channel on the guild.
  """
  @spec leave_voice(guild_id :: Snowflake.t()) :: :ok
  def leave_voice(guild_id) do
    guild_id
    |> Api.update_voice_state(nil)
  end

  @doc """
  Check if the bot can connect to a specific voice channel.
  """
  @spec can_connect?(guild_id :: Snowflake.t(), voice_id :: Snowflake.t()) :: boolean()
  def can_connect?(guild_id, voice_id) do
    perms =
      VoicePermissions.my_channel_permissions(guild_id, voice_id)

    perms.administrator || perms.connect
  end

  defguard positive_integer(value) when is_integer(value) and value > 0

  @doc """
  Play the music with a max retry amount. If the retry amount is less than zero it will just fail automatically.
  Every retry approx lasts for approx. `100ms`.
  """
  @spec play_when_ready(link :: String.t(), guild_id :: Snowflake.t(), max_retries :: integer()) :: {:ok, :ok | any()} | {:error, :failed_max}
  def play_when_ready(link, guild_id, max_retries) when is_integer(max_retries) and max_retries > 0 do
    if Nostrum.Voice.ready?(guild_id) do
      {:ok, Nostrum.Voice.play(guild_id, link, :ytdl)}
    else
      :timer.sleep(100)
      play_when_ready(link, guild_id, max_retries - 1)
    end
  end

  def play_when_ready(_, _, _) do
    {:ok, :failed_max}
  end

  @doc """
  Play the music without a max retry. This in theory can infinitely loop if the bot is never ready to play music.

  See `play_when_ready/3` as a safe way to play this.
  """
  def play_when_ready!(link, guild_id) do
    if Nostrum.Voice.ready?(guild_id) do
      Nostrum.Voice.play(guild_id, link, :ytdl)
    else
      :timer.sleep(100)
      play_when_ready!(link, guild_id)
    end
  end

  @doc """
  Check whether a link is a YouTube one.
  """
  @spec youtube_link?(url :: String.t()) :: boolean()
  def youtube_link?(url) do
    url =
      "https://www.youtube.com/oembed?url=#{url}&format=json"

    headers = [
      "User-agent": "#{Artificer.username!()} #{Artificer.version!}",
      "Accept": "Application/json; Charset=utf-8"
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        true
      _ ->
        false
    end
  end
end
