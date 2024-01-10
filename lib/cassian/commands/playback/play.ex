defmodule Cassian.Commands.Playback.Play do
  use Cassian.Behaviours.Command

  import Cassian.Utils
  alias Cassian.Utils.Embed, as: EmbedUtils
  alias Cassian.Utils.Voice, as: VoiceUtils
  alias Cassian.Managers.{MessageManager, PlayManager}

  # Main logic pipe

  def execute(message, args) do
    handle_request(message, args)
  end

  @doc """
  Handle the request. Continues with the rest of the logic pipe or
  sends an embed message that the user isn't connected to channel.
  """
  def handle_request(message, args) do
    with {:ok, {_guild_id, voice_id}} <- VoiceUtils.sender_voice_id(message),
         {:voice_connect, true} <- {:voice_connect, VoiceUtils.can_connect?(message.guild_id, voice_id)},
         {:ok, metadata} <- song_metadata(Enum.fetch!(args, 0)) do

      VoiceUtils.join_or_switch_voice(message.guild_id, voice_id)
      PlayManager.insert!(message.guild_id, message.channel_id, metadata)
      PlayManager.play_if_needed(message.guild_id)
      MessageManager.disable_embed(message)
    else
      {:error, :not_in_voice} ->
        no_channel_error(message)
      {:voice_connect, false} ->
        no_permissions_error(message)
      {:error, :no_metadata} ->
        invalid_link_error(message)
    end
  end

  # Error handlers

  @doc """
  Generate and send the embed for when a user isn't in a voice channel.
  """
  def no_channel_error(message) do
    EmbedUtils.generate_error_embed(
      "Hey you... You're not in a voice channel.",
      "I can't play any music if you're not a voice channel. Join one first."
    )
    |> MessageManager.send_dissapearing_embed(message.channel_id)
  end

  @doc """
  Generate and send the embed for when the bot doesn't have permissions to view, connect or
  speak in a channel.
  """
  def no_permissions_error(message) do
    EmbedUtils.generate_error_embed(
      "And how do you think that's possible?",
      "I don't have the permissions to play music there... Fix it up first."
    )
    |> MessageManager.send_dissapearing_embed(message.channel_id)
  end

  @doc """
  Tell the user that the link is not valid.
  """
  def invalid_link_error(message) do
    EmbedUtils.generate_error_embed(
      "Yeah, that won't work.",
      "The link you tried to provide me isn't working. Recheck it."
    )
    |> MessageManager.send_dissapearing_embed(message.channel_id)
  end
end
