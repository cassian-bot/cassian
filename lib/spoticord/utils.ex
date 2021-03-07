defmodule Spoticord.Utils do
  @moduledoc """
  Module for general utils...
  """
  alias Nostrum.Cache.{GuildCache, ChannelCache}
  alias Nostrum.Struct.Guild.Member
  alias Nostrum.Struct.Embed
  alias Nostrum.Api

  import Embed

  @doc """
  Add a color on an embed. The `color` params ia a hex string value of the color.
  It will be automaically converted to something Discord can use.
  """
  @spec put_color_on_embed(embed :: Embed, color :: String.t()) :: Embed
  def put_color_on_embed(embed, color \\ "#1DB954") do
    {color, _} =
      color
      |> String.replace_leading("#", "")
      |> Integer.parse(16)

    put_color(embed, color)
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

  def join_or_switch_voice(guild_id, channel_id) do
    guild_id
    |> Api.update_voice_state(channel_id, false, true)
  end

  def leave_voice(guild_id) do
    guild_id
    |> Api.update_voice_state(nil)
  end

  alias Spoticord.Structs.VoicePermissions

  def can_connect?(guild_id, voice_id) do
    perms =
      VoicePermissions.my_channel_permissions(guild_id, voice_id)

    perms.administrator || perms.connect
  end
end
