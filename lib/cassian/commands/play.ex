defmodule Cassian.Commands.Play do
  use Cassian.Behaviours.Command

  import Cassian.Utils
  alias Cassian.Utils.Embed, as: EmbedUtils
  alias Cassian.Utils.Voice, as: VoiceUtils
  alias Cassian.Managers.{MessageManager, PlayManager}

  def ship?, do: true
  def caller, do: "play"
  def desc, do: "Play music in your voice channel!"

  # Main logic pipe

  def execute(message, args) do
    handle_request(message, args)
  end

  @doc """
  Handle the request. Continues with the rest of the logic pipe or
  sends an embed message that the user isn't connected to channel.
  """
  def handle_request(message, args) do
    case VoiceUtils.get_sender_voice_id(message) do
      {:ok, {_guild_id, voice_id}} ->
        handle_connect_possibility(message, voice_id, args)

      # THe user is not in a voice channel...
      {:error, :noop} ->
        no_channel_error(message)
    end
  end

  @doc """
  Determine whether you have the possiblity to connect. Continues
  with the rest of the logic pipe or sends an embed message
  that the bot doesn't have permission to connect.
  """
  def handle_connect_possibility(message, voice_id, args) do
    if VoiceUtils.can_connect?(message.guild_id, voice_id),
      do: handle_metadata(message, voice_id, args),
      else: no_permissions_error(message)
  end

  @doc """
  It is determined that the caller user is in a voice channel and that the bot has permissions
  to connect. Awesome. Now check if the link metadata is correct. If it is correct, continue with the
  logic pipe or send an embed that the link is not correct.
  """
  def handle_metadata(message, voice_id, args) do
    case youtube_metadata(Enum.fetch!(args, 0)) do
      {true, metadata} ->
        handle_connect(message, voice_id, metadata)

      {false, :noop} ->
        invalid_link_error(message)
    end
  end

  @doc """
  Everything is A-ok. You can connect and the link is valid. Connect to the voice channel and
  cache the voice state. Continue wth the pipeline.
  """
  def handle_connect(message, voice_id, metadata) do
    VoiceUtils.join_or_switch_voice(message.guild_id, voice_id)
    PlayManager.insert!(message.guild_id, message.channel_id, metadata)
    PlayManager.play_if_needed(message.guild_id)
    MessageManager.disable_embed(message)
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
